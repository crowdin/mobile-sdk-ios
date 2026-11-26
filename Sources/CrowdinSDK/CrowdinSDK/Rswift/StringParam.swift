//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//
//  Parts of the content of this file are loosly based on StringsFileParser.swift from SwiftGen/GenumKit.
//  We don't feel this is a "substantial portion of the Software" so are not including their MIT license,
//  eventhough we would like to give credit where credit is due by referring to SwiftGen thanking Olivier
//  Halligon for creating SwiftGen and GenumKit.
//
//  See: https://github.com/AliSoftware/SwiftGen/blob/master/GenumKit/Parsers/StringsFileParser.swift
//

import Foundation

enum FormatPart: Equatable {
	case spec(FormatSpecifier)
	case reference(String)

	var formatSpecifier: FormatSpecifier? {
		switch self {
		case .spec(let formatSpecifier):
			return formatSpecifier

		case .reference:
			return nil
		}
	}

	static func formatParts(formatString: String) -> [FormatPart]? {
		return createFormatParts(formatString)
	}
}

// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265-SW1
enum FormatSpecifier {
	case object
	case double
	case int
	case uInt
	case character
	case cStringPointer
	case voidPointer
	case topType

	var type: String {
		switch self {
		case .object:
			return "String"
		case .double:
			return "Double"
		case .int:
			return "Int"
		case .uInt:
			return "UInt"
		case .character:
			return "Character"
		case .cStringPointer:
			return "CStringPointer"
		case .voidPointer:
			return "VoidPointer"
		case .topType:
			return "Any"
		}
	}
}

extension FormatSpecifier {
	// Convenience initializer, uses last character of string,
	// ignoring lengt modifiers, e.g. "lld"
	init?(formatString string: String) {
		guard let last = string.last else {
			return nil
		}

		self.init(formatChar: last)
	}

	// Case-sensitive whitelist of CoreFoundation conversions: `%P` and `%S` are NOT
	// aliases of `%p`/`%s` (CoreFoundation crashes on both), so letters must not be lowercased.
	init?(formatChar char: Swift.Character) {
		switch char {
		case "@":
			self = .object
		case "a", "A", "e", "E", "f", "F", "g", "G":
			self = .double
		case "d", "D", "i":
			self = .int
		case "o", "O", "u", "U", "x", "X":
			self = .uInt
		case "c", "C":
			self = .character
		case "s":
			self = .cStringPointer
		case "p":
			self = .voidPointer
		default:
			return nil
		}
	}
}

/// Display-side regex for `isFormated`, `findMatch`, and `findValues`.
/// Safety validation uses `createFormatParts` instead (regexes fail open on unknown specifiers).
let formatTypesRegEx: NSRegularExpression = {
	let patternLength = "(?:h|hh|l|ll|q|z|t|j|L)?"
	let patternInt = "\(patternLength)([dioux]|[aefg])" // %d/%i/%o/%u/%x and %a/%e/%f/%g with optional length modifiers
	let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
	let precision = "[-+]?\\d*(?:\\.\\d*)?" // precision like in "%1.2f" or "%012.10"
	let reference = "#@([^@]+)@" // reference to NSStringFormatSpecType in .stringsdict

	do {
		return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(patternInt)|[csp]|\(reference))", options: [.caseInsensitive])
	} catch {
		fatalError("Error building the regular expression used to match string formats")
	}
}()

/// Caps positional indices (e.g. `%5$d`) and slot count to prevent large padding allocations.
private let maxPositionalIndex = 100

/// Caps literal width/precision (e.g. `%256d`) to prevent `String(format:)` memory exhaustion.
private let maxFieldWidth = 256

/// Tracks argument slots consumed by a format string.
private struct FormatSlots {
	private var slots = [Int: FormatPart]()
	private var nextSequential = 1
	private var usesPositional = false
	private var usesSequential = false

	/// Registers a slot at `position` (or next sequential index).
	/// Rejects mixed positional/sequential, out-of-range indices, or conflicting types.
	mutating func add(_ part: FormatPart, at position: Int?) -> Bool {
		let index: Int
		if let position = position {
			usesPositional = true
			index = position
		} else {
			usesSequential = true
			index = nextSequential
			nextSequential += 1
		}
		guard !(usesPositional && usesSequential), index >= 1, index <= maxPositionalIndex else { return false }
		if let existing = slots[index], existing != part { return false }
		slots[index] = part
		return true
	}

	/// Slots in argument order; unread positional gaps are padded with `.topType`.
	var parts: [FormatPart] {
		let count = slots.keys.max() ?? 0
		return (0..<count).map { slots[$0 + 1] ?? .spec(.topType) }
	}
}

/// `[A-Za-z0-9_]`: names CoreFoundation treats as a stringsdict reference.
private func isReferenceNameScalar(_ scalar: Unicode.Scalar) -> Bool {
	switch scalar {
	case "A"..."Z", "a"..."z", "0"..."9", "_": return true
	default: return false
	}
}

// "I give %d apples to %@ %#@named@" --> [.spec(.int), .spec(.object), .reference("named")]
//
// CoreFoundation format grammar scanner: %[n$][flags][width][.precision][length]conversion
// Fails closed (returns `nil`) on:
// - `*` dynamic width/precision or `%n` (consumes/writes an argument slot)
// - `%P`/`%S` (consume an argument; CoreFoundation crashes on them)
// - malformed modifiers (e.g. `%5%`, trailing `$`, mixed positional/sequential, type conflicts)
// - positions > `maxPositionalIndex` or widths/precisions > `maxFieldWidth`
// Unknown conversions (e.g. `%y`) are printed literally by CoreFoundation and skipped.
private func createFormatParts(_ formatString: String) -> [FormatPart]? {
	let s = Array(formatString.unicodeScalars)
	var slots = FormatSlots()
	var i = 0

	func isDigit(_ index: Int) -> Bool {
		return index < s.count && s[index].value >= 0x30 && s[index].value <= 0x39
	}

	/// Reads decimal digits from `index`, saturating at `1_000_000`.
	func readNumber(from index: Int) -> (value: Int, next: Int) {
		var value = 0
		var next = index
		while isDigit(next) {
			value = min(value * 10 + Int(s[next].value - 0x30), 1_000_000)
			next += 1
		}
		return (value, next)
	}

	while i < s.count {
		guard s[i] == "%" else { i += 1; continue }
		var j = i + 1
		guard j < s.count else { break }
		if s[j] == "%" { i = j + 1; continue } // literal percent

		// Optional positional index (`%2$d`); leading `0` is a flag.
		var position: Int?
		if isDigit(j), s[j] != "0" {
			let number = readNumber(from: j)
			if number.next < s.count, s[number.next] == "$" {
				guard number.value <= maxPositionalIndex else { return nil }
				position = number.value
				j = number.next + 1
			}
		}

		// Stringsdict reference: "%#@name@".
		if j + 1 < s.count, s[j] == "#", s[j + 1] == "@" {
			var end = j + 2
			while end < s.count, s[end] != "@" {
				// `%` inside `%#@...@` causes Foundation to reject the reference and parse inner specifiers.
				if s[end] == "%" { return nil }
				end += 1
			}
			// CoreFoundation only resolves identifier-like names; for any other name it parses
			// `%#@` as a `#`-flagged `%@` object conversion, so fall through to the generic scan below.
			if end < s.count, end > j + 2, s[(j + 2)..<end].allSatisfy(isReferenceNameScalar) {
				let name = String(String.UnicodeScalarView(s[(j + 2)..<end]))
				guard slots.add(.reference(name), at: position) else { return nil }
				i = end + 1
				continue
			}
		}

		// CoreFoundation parses flags, width, precision, and length in one loop
		// (allowing arbitrary order and 3+ length chars like `%lllp`).
		while j < s.count {
			let ch = s[j]
			if "-+ #0'".unicodeScalars.contains(ch) {
				j += 1
			} else if ch == "*" || ch == "$" {
				return nil
			} else if isDigit(j) {
				let number = readNumber(from: j)
				// Reject malformed `$` after modifiers (e.g. `%+1$d`, `%1$2$d`).
				if number.next < s.count, s[number.next] == "$" { return nil }
				guard number.value <= maxFieldWidth else { return nil }
				j = number.next
			} else if ch == "." {
				j += 1
				if j < s.count, s[j] == "*" { return nil }
				let number = readNumber(from: j)
				guard number.value <= maxFieldWidth else { return nil }
				j = number.next
			} else if "hlqLztj".unicodeScalars.contains(ch) {
				j += 1
			} else {
				break
			}
		}

		// Conversion.
		guard j < s.count else { break }
		let conversion = s[j]
		// `%n` writes memory; `%P`/`%S` consume an argument but crash CoreFoundation.
		if "%nNPS".unicodeScalars.contains(conversion) { return nil }
		if let specifier = FormatSpecifier(formatChar: Character(conversion)) {
			guard slots.add(.spec(specifier), at: position) else { return nil }
		}
		i = j + 1
	}

	return slots.parts
}
