//
//  String.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

// MARK: - String localization extension.
extension String {
	/// Extension method for simplifying strings localization.
    // swiftlint:disable identifier_name
	public var cw_localized: String {
		return NSLocalizedString(self, comment: .empty)
	}

    /// Extension method for simplifying strings localization with argumets.
    ///
    /// Uses the SDK's active localization locale so that CLDR plural rules
    /// (`.stringsdict`) are resolved for the correct language — not the device
    /// locale (`Locale.current`).
    ///
    /// - Parameter arguments: Formatted string arguments.
    /// - Returns: Localized formatted string.
    public func cw_localized(with arguments: [CVarArg]) -> String {
        let translation = NSLocalizedString(self, comment: .empty)
        return String.cw_safeFormat(translation, arguments: arguments, fallbackKey: self)
    }

    /// Extension method for simplifying strings localization with argumets.
    ///
    /// Uses the SDK's active localization locale so that CLDR plural rules
    /// (`.stringsdict`) are resolved for the correct language — not the device
    /// locale (`Locale.current`).
    ///
    /// - Parameter args: Formatted string arguments.
    /// - Returns: Localized formatted string.
    public func cw_localized(with args: CVarArg...) -> String {
        let translation = NSLocalizedString(self, comment: .empty)
        return String.cw_safeFormat(translation, arguments: args, fallbackKey: self)
    }

    /// Returns a `Locale` matching the SDK's active localization so that
    /// `String(format:locale:arguments:)` applies the correct CLDR plural rules.
    /// Falls back to `Locale.current` when the SDK has not been started.
    static var crowdinLocale: Locale {
        guard let localization = Localization.current else {
            return Locale.current
        }

        let lang = Localization.currentLocalization ?? localization.provider.localization
        return Locale(identifier: lang)
    }
}

// MARK: - Format string safety.
extension String {
    /// Formats `value` with `arguments` via `String(format:)`, but only trusts
    /// `value` itself as the format string when it is safe for `arguments`.
    ///
    /// `value` is typically a translation downloaded over the air, which a
    /// translator can edit - the lowest privileged contributor role. Nothing
    /// guarantees it carries the same format specifiers the app was built against,
    /// and `String(format:)` does not check that either: extra specifiers read past
    /// the end of `arguments`, and a specifier from the wrong category misreads the
    /// argument that's there (CWE-134). When `value` isn't safe, this falls back to
    /// the app's own bundled localization for `fallbackKey`, which is authored by
    /// the developer and therefore always matches `arguments`.
    ///
    /// - Parameters:
    ///   - value: The candidate format string, e.g. a downloaded translation.
    ///   - arguments: The arguments the app supplied for formatting.
    ///   - fallbackKey: The localization key to fall back to when `value` isn't safe.
    /// - Returns: The formatted string.
    static func cw_safeFormat(_ value: String, arguments: [CVarArg], fallbackKey: String) -> String {
        let safeValue = value.isSafeFormatString(arguments: arguments) ? value : Bundle.bundledLocalizedString(forKey: fallbackKey)
        return String(format: safeValue, locale: String.crowdinLocale, arguments: arguments)
    }

    /// Whether `self` is safe to pass to `String(format:)` together with `arguments`.
    ///
    /// - Parameter arguments: The arguments that would be supplied for formatting.
    /// - Returns: `true` if every format specifier in `self` is covered by
    ///   `arguments` and matches its broad category (object vs. numeric).
    func isSafeFormatString(arguments: [CVarArg]) -> Bool {
        // nil means the parser found a malformed/oversized positional
        // specifier - the format cannot be trusted.
        guard let parts = FormatPart.formatParts(formatString: self) else { return false }
        guard parts.count <= arguments.count else { return false }
        for (index, part) in parts.enumerated() {
            switch part {
            case .spec(let specifier):
                guard specifier.isCompatible(with: arguments[index]) else { return false }
            case .reference:
                // Stringsdict plural references format numeric values; reject
                // non-scalars so an OTA stringsdict cannot reinterpret an object
                // pointer as an integer.
                guard FormatSpecifier.isDefinitelyScalar(arguments[index]) else { return false }
            }
        }
        return true
    }
}

private extension FormatSpecifier {
    /// Whether a value of `argument`'s runtime type is safe to read for this
    /// specifier. `String(format:)` reads a fixed-size word for whichever specifier
    /// the format string names, regardless of what was actually passed at that
    /// position, so a specifier from the wrong category re-interprets that word:
    /// `%@` on a plain number dereferences a bogus pointer (crash), and a numeric
    /// specifier on a `String` prints its bridged pointer as a number (an
    /// ASLR-relevant leak). `%s` on anything that is not a C-string pointer
    /// dereferences the word as `char *` and crashes (verified on Apple
    /// Foundation), and `%p` on a `String` or object prints its address.
    /// This only rejects those unambiguous cases and otherwise defers to the
    /// value - a narrow, defense in depth check alongside the argument-count
    /// check above, not a full type checker.
    func isCompatible(with argument: CVarArg) -> Bool {
        switch self {
        case .object:
            // `%@` sends an ObjC message to the argument word; scalars hold a
            // bogus pointer and raw Unsafe pointers hold a non-object address -
            // both crash with EXC_BAD_ACCESS.
            return !Self.isDefinitelyScalar(argument) && !Self.isDefinitelyPointer(argument)
        case .double, .int, .uInt, .character:
            // Only scalar values are safe here: objects (String, NSURL,
            // NSNumber, etc.) and raw pointers would leak their addresses
            // as numbers (ASLR leak).
            return Self.isDefinitelyScalar(argument)
        case .cStringPointer:
            return Self.isDefinitelyCStringPointer(argument)
        case .voidPointer:
            // `%p` only prints the word; scalars and any pointer are memory-safe.
            // Rejecting String/objects is deliberate: their words are live
            // addresses, and printing them would leak ASLR-relevant pointers.
            return Self.isDefinitelyScalar(argument) || Self.isDefinitelyPointer(argument)
        case .topType:
            // Only used to pad unread positions in a positional format.
            return true
        }
    }

    static func isDefinitelyScalar(_ argument: CVarArg) -> Bool {
        // Class instances (e.g. NSNumber) bridge to Swift numeric types under
        // `is Int`/`is Double`, but CVarArg passes their object pointer word,
        // not the boxed scalar value.
        if Swift.type(of: argument) is AnyClass { return false }
        #if canImport(CoreGraphics)
        if argument is CGFloat { return true }
        #endif
        switch argument {
        case is Int, is Int8, is Int16, is Int32, is Int64,
             is UInt, is UInt8, is UInt16, is UInt32, is UInt64,
             is Double, is Float,
             is Bool:
            return true
        default:
            return false
        }
    }

    /// Whether `argument` is any `Unsafe*Pointer` type. There is no common
    /// protocol to cast to, so the dynamic type name is inspected - a
    /// pragmatic check whose failure mode (a rejected safe translation falling
    /// back to the bundled string) is harmless.
    static func isDefinitelyPointer(_ argument: CVarArg) -> Bool {
        // `Swift.type` disambiguates from FormatSpecifier's own `type` property.
        let name = String(describing: Swift.type(of: argument))
        return name.hasPrefix("Unsafe") && name.contains("Pointer")
    }

    /// Whether `argument` is an actual C-string pointer, the only thing `%s`
    /// can safely read. Both `Int8` and `UInt8` pointees are accepted - byte
    /// buffers from `Data.withUnsafeBytes` yield `UnsafePointer<UInt8>`.
    /// (`UnsafeRawPointer` is omitted because it does not conform to
    /// `CVarArg`, so it can never appear here.)
    static func isDefinitelyCStringPointer(_ argument: CVarArg) -> Bool {
        switch argument {
        case is UnsafePointer<Int8>, is UnsafeMutablePointer<Int8>,
             is UnsafePointer<UInt8>, is UnsafeMutablePointer<UInt8>:
            return true
        default:
            return false
        }
    }
}

// MARK: - Formatting detection.
extension String {
    /// Replaces each `%%` literal-percent escape with U+0001 so the format
    /// regex sees the real specifiers. `formatTypesRegEx` only has a
    /// one-character `(?<!%)` lookbehind, which would otherwise hide a genuine
    /// specifier following an escape ("%%%d" is literal "%" plus a real "%d").
    /// The display-side regex consumers (`isFormated`,
    /// `findMatch`, `findValues`) apply this so they agree on where the
    /// specifiers are (CWE-134). The placeholder never appears in real strings;
    /// consumers that search rendered text substitute it back to `%`.
    var formatStringWithMaskedLiteralPercents: String {
        return replacingOccurrences(of: "%%", with: "\u{1}")
    }

    /// Detect whether current string is formated.
	var isFormated: Bool {
        let masked = formatStringWithMaskedLiteralPercents
		return formatTypesRegEx.matches(in: masked, options: [], range: NSRange(location: 0, length: (masked as NSString).length)).count > 0
	}
}

// MARK: - Static strings.
extension String {
    static let dot = "."
    static let empty = ""
    static let enter = "\n"
    static let pathDelimiter = "/"
    static let minus = "-"
}

// MARK: - Match finding.
extension String {
    /// Detect whether formated string mached to a given string.
    /// Additional explentaion:
    /// For example if we want to check whether formated string "my %@ value" is matchin to string "my awesome value".
    /// The result will be true as all strings parts from formated string("my ", " value") are included in string "my awesome value".
    ///
    /// - Parameters:
    ///   - formatedString: Formated string.
    ///   - string: String to check match.
    /// - Returns: Bool value which indicates whether given string metches with formated string.
    static func findMatch(for formatedString: String, with string: String) -> Bool {
        // Check is it equal:
        if formatedString == string { return true }
        // If not try to parse localized string as formated. Literal `%%` escapes
        // are masked so the regex sees the same specifiers as the safety check
        // (see formatStringWithMaskedLiteralPercents).
        let masked = formatedString.formatStringWithMaskedLiteralPercents
        let nsMaskedValue = masked as NSString
        let matches = formatTypesRegEx.matches(in: masked, options: [], range: NSRange(location: 0, length: nsMaskedValue.length))
        // If it is not formated string return false.
        guard matches.count > 0 else { return false }
        let ranges = matches.compactMap({ $0.range })
        let components = nsMaskedValue.splitBy(ranges: ranges)
        for component in components {
            // A masked literal percent was rendered as a real "%" in `string`.
            let rendered = component.replacingOccurrences(of: "\u{1}", with: "%")
            if !string.contains(rendered) {
                return false
            }
        }
        return true
    }
}

// MARK: - NSString splitting.
extension NSString {
    /// Spit current string by a given ranges.
    /// Additional explenation:
    /// For example we have string "Awesome string" and we want to split it by range (7,1). Result arrayy will be: ["Awesome", "string"]
    ///
    /// - Parameter ranges: Array of renges to split by.
    /// - Returns: Array of substrings
    func splitBy(ranges: [NSRange]) -> [String] {
        var values = [String]()
        // `0...(-1)` traps; an empty ranges array simply yields no splits.
        guard !ranges.isEmpty else { return values }
        for index in 0...ranges.count - 1 {
            let range = ranges[index]
            guard range.location != NSNotFound else { continue }
            if index == 0 {
                if range.location != 0 {
                    guard self.isValid(range: range) else { continue }
                    values.append(self.substring(with: NSRange(location: 0, length: range.location)))
                }
            } else {
                let previousRange = ranges[index - 1]
                let location = previousRange.location + previousRange.length
                let substringRange = NSRange(location: location, length: range.location - location)
                guard self.isValid(range: substringRange) else { continue }
                values.append(self.substring(with: substringRange))
            }
            if index == ranges.count - 1 {
                if range.location + range.length == self.length { continue }
                let location = range.location + range.length
                let substringRange = NSRange(location: location, length: self.length - location)
                guard self.isValid(range: substringRange) else { continue }
                values.append(self.substring(with: substringRange))
            }
        }
        return values
    }

    /// Detect whether given range is valid and is it avalaible to use for current string.
    ///
    /// - Parameter range: NSRange value for checking.
    /// - Returns: Bool value which indicates whether passed range is valid for current string.
    private func isValid(range: NSRange) -> Bool {
        return range.location != NSNotFound && range.location + range.length <= length && range.length > 0
    }
}

// MARK: - Values finding.
extension String {
    /// Method for values detection passed for localization string creation for given string and format string.
    /// Additional explenation:
    /// For example, we have a string "String with string parameter - test, and an integer parameter - 2".
    /// The format string is "String with string parameter - %@, and integer parameter - %llu".
    /// Result of this method will be an array of two objects - ["test", 2].
    ///
    /// - Parameters:
    ///   - string: String for searching values.
    ///   - format: Format string.
    /// - Returns: An array of detected values in a given string with a given format. If passed format doesn't match with string nil will be returned.
    static func findValues(for string: String, with format: String) -> [Any]? {
        // Literal `%%` escapes are masked so the regex and formatParts agree on
        // the specifier positions (see formatStringWithMaskedLiteralPercents);
        // components are searched for in `string` with the mask rendered back
        // as a real "%", because that is how the app displayed them.
        let masked = format.formatStringWithMaskedLiteralPercents
        let nsStringValue = masked as NSString
        guard let parts = FormatPart.formatParts(formatString: format) else { return nil }
        let matches = formatTypesRegEx.matches(in: masked, options: [], range: NSRange(location: 0, length: nsStringValue.length))
        guard matches.count > 0 else { return nil }
        let ranges = matches.compactMap({ $0.range })
        let components = nsStringValue.splitBy(ranges: ranges)

        let nsStringText = string as NSString

        var valueRanges = [NSRange]()
        components.forEach({
            let rendered = $0.replacingOccurrences(of: "\u{1}", with: "%")
            valueRanges.append(nsStringText.range(of: rendered))
        })

        guard valueRanges.count > 0 else { return nil }

        let values = nsStringText.splitBy(ranges: valueRanges)

        guard values.count == parts.count else { return nil }

        var result = [Any]()

        guard !parts.isEmpty else { return nil }
        for index in 0...parts.count - 1 {
            let part = parts[index]
            let value = values[index]
            guard let formatSpecifier = part.formatSpecifier else {
                result.append(value)
                continue
            }
            var formatValue: Any?
            switch formatSpecifier {
            case .object: formatValue = value
            case .double: formatValue = Double(value)
            case .int: formatValue = Int(value)
            case .uInt: formatValue = UInt(value)
            case .character: formatValue = Character(value)
            case .cStringPointer: formatValue = value
            case .voidPointer: formatValue = value
            case .topType: formatValue = value
            }
            guard let nonNilFormatValue = formatValue else { return nil }
            result.append(nonNilFormatValue)
        }

        return result
    }
}
