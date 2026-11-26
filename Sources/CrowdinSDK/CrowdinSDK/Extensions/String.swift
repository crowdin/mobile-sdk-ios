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

    /// Active SDK locale for CLDR plural rules; falls back to `Locale.current` before SDK startup.
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
    /// Formats `value` with `arguments`, falling back to the bundled string for `fallbackKey`
    /// if `value` fails CWE-134 validation (extra specifiers or mismatched argument types).
    static func cw_safeFormat(_ value: String, arguments: [CVarArg], fallbackKey: String) -> String {
        let safeValue = value.isSafeFormatString(arguments: arguments) ? value : Bundle.bundledLocalizedString(forKey: fallbackKey)
        return String(format: safeValue, locale: String.crowdinLocale, arguments: arguments)
    }

    /// Returns `true` if all specifiers in `self` are covered by `arguments` and match their expected types.
    func isSafeFormatString(arguments: [CVarArg]) -> Bool {
        // `nil` indicates a malformed or oversized specifier.
        guard let parts = FormatPart.formatParts(formatString: self) else { return false }
        guard parts.count <= arguments.count else { return false }
        for (index, part) in parts.enumerated() {
            switch part {
            case .spec(let specifier):
                guard specifier.isCompatible(with: arguments[index]) else { return false }
            case .reference:
                // Stringsdict plural references format numeric values; reject non-scalars.
                guard FormatSpecifier.isDefinitelyScalar(arguments[index]) else { return false }
            }
        }
        return true
    }
}

private extension FormatSpecifier {
    /// Defense-in-depth type check: rejects mismatches that crash (`%@` on scalar, `%s` on non-C-string)
    /// or leak object addresses (`%d`/`%x`/`%p` on `String`/objects).
    func isCompatible(with argument: CVarArg) -> Bool {
        switch self {
        case .object:
            // `%@` sends an ObjC message; scalars and raw pointers crash with EXC_BAD_ACCESS.
            return !Self.isDefinitelyScalar(argument) && !Self.isDefinitelyPointer(argument)
        case .double, .int, .uInt, .character:
            // Reject objects and raw pointers to prevent pointer/ASLR leaks.
            return Self.isDefinitelyScalar(argument)
        case .cStringPointer:
            return Self.isDefinitelyCStringPointer(argument)
        case .voidPointer:
            // Allow scalars and raw pointers; reject objects to prevent pointer/ASLR leaks.
            return Self.isDefinitelyScalar(argument) || Self.isDefinitelyPointer(argument)
        case .topType:
            // Unused positional padding slot.
            return true
        }
    }

    static func isDefinitelyScalar(_ argument: CVarArg) -> Bool {
        // NSNumber and other classes bridge to Swift numeric types via `is`,
        // but CVarArg passes their object pointer rather than the boxed value.
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

    /// Matches `Unsafe*Pointer` types via type name (no shared protocol).
    /// False negatives safely fall back to bundled strings.
    static func isDefinitelyPointer(_ argument: CVarArg) -> Bool {
        // Disambiguate from FormatSpecifier.type.
        let name = String(describing: Swift.type(of: argument))
        return name.hasPrefix("Unsafe") && name.contains("Pointer")
    }

    /// Matches C-string pointers (`Int8`/`UInt8` for `Data.withUnsafeBytes`; `UnsafeRawPointer` is not `CVarArg`).
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
    /// Replaces `%%` with `\u{1}` so `formatTypesRegEx`'s single-char `(?<!%)` lookbehind
    /// sees specifiers after escapes (e.g. `%%%d`). Callers searching rendered text map it back to `%`.
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
