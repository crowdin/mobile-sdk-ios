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

	init?(formatChar char: Swift.Character) {
        guard let lcChar = Swift.String(char).lowercased().first else { return nil }
		switch lcChar {
		case "@":
			self = .object
		case "a", "e", "f", "g":
			self = .double
		case "d", "i":
			self = .int
		case "o", "u", "x":
			self = .uInt
		case "c":
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

/// Regex used by the display-side helpers (`isFormated`, `findMatch`,
/// `findValues`) to locate specifiers inside rendered text. It is NOT used to
/// decide whether a format string is safe to hand to `String(format:)`:
/// a regex only recognises the specifiers it was written for, and anything it
/// misses is an argument `String(format:)` reads that nobody counted (CWE-134).
/// The safety check uses `createFormatParts` below, which follows the
/// CoreFoundation grammar and fails closed.
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

/// Upper bound on a positional specifier index (e.g. the `5` in `%5$d`) and on
/// the number of argument slots a format may use. Real localizations never come
/// close; the bound exists because a malicious OTA translation could otherwise
/// name an enormous position and force this parser - which runs *inside* the
/// CWE-134 safety check - to allocate a padding array of that size.
private let maxPositionalIndex = 100

/// Upper bound on a literal width or precision (the `10` in `%10d`, the `5` in
/// `%.5f`). `String(format:)` materialises the padding, so an unbounded value is
/// a memory exhaustion vector.
private let maxFieldWidth = 256

/// Collects the argument slots a format string consumes.
private struct FormatSlots {
	private var slots = [Int: FormatPart]()
	private var nextSequential = 1
	private var usesPositional = false
	private var usesSequential = false

	/// Registers a slot. `position` is the explicit `n$` index, or nil to take the
	/// next sequential one. Returns false when the format must be rejected:
	/// mixing sequential and positional specifiers (CoreFoundation's behaviour is
	/// not worth relying on), an out-of-range position, or one position read as
	/// two different types.
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

	/// Slots in argument order; positions the format never reads are padded with `.topType`.
	var parts: [FormatPart] {
		let count = slots.keys.max() ?? 0
		return (0..<count).map { slots[$0 + 1] ?? .spec(.topType) }
	}
}

// "I give %d apples to %@ %#@named@" --> [.Spec(.Int), .Spec(.String), .Reference("named")]
//
// Returns one entry per argument `String(format:)` will consume for `formatString`
// (CWE-134: the caller compares this count and the types with the arguments it
// actually has). This is a scanner over the CoreFoundation format grammar -
//   %[n$][flags][width][.precision][length]conversion
// - rather than a regex, so it counts everything CoreFoundation counts. Where it
// cannot be sure, it returns nil and callers must treat the format as unsafe:
//   - `*` width/precision: takes its value from an argument and can force a huge
//     allocation, and no real translation needs it;
//   - `%n`: consumes an argument slot (verified on Apple Foundation) and has no
//     legitimate use in a translation;
//   - flags/width followed by a second `%` (e.g. "%5%"): how the tail is
//     re-interpreted is not worth guessing;
//   - widths/precisions/positions above the caps, mixed sequential and
//     positional specifiers, or one position read as two different types.
// A `%` followed by an unknown conversion character (e.g. "%y") is printed
// literally by CoreFoundation and consumes nothing (verified), so it is skipped.
private func createFormatParts(_ formatString: String) -> [FormatPart]? {
	let s = Array(formatString.unicodeScalars)
	var slots = FormatSlots()
	var i = 0

	func isDigit(_ index: Int) -> Bool {
		return index < s.count && s[index].value >= 0x30 && s[index].value <= 0x39
	}

	/// Reads a run of decimal digits starting at `index`. Saturates instead of overflowing.
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

		// Optional explicit position: "%2$d". A leading 0 is a flag, not a position.
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
				// A `%` inside `%#@...@` causes Foundation to reject the
				// reference and execute the inner specifier instead (CWE-134).
				if s[end] == "%" { return nil }
				end += 1
			}
			if end < s.count, end > j + 2 {
				let name = String(String.UnicodeScalarView(s[(j + 2)..<end]))
				guard slots.add(.reference(name), at: position) else { return nil }
				i = end + 1
				continue
			}
		}

		// Modifiers: CoreFoundation parses flags, width, precision, and length
		// modifiers in a single loop (accepting arbitrary order and 3+ length
		// modifiers like `%lllp` or `%l+p`), so we mirror that loop here.
		while j < s.count {
			let ch = s[j]
			if "-+ #0'".unicodeScalars.contains(ch) {
				j += 1
			} else if ch == "*" || ch == "$" {
				return nil
			} else if isDigit(j) {
				let number = readNumber(from: j)
				// A positional `$` after modifiers (e.g. `%+1$d`, `%1$2$d`) is
				// malformed and not worth guessing about.
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
		if conversion == "%" || conversion == "n" || conversion == "N" { return nil }
		if let specifier = FormatSpecifier(formatChar: Character(conversion)) {
			guard slots.add(.spec(specifier), at: position) else { return nil }
		}
		i = j + 1
	}

	return slots.parts
}
