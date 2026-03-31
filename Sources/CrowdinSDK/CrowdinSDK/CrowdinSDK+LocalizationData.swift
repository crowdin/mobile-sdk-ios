//
//  CrowdinSDK+LocalizationData.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 31.03.2026.
//

import Foundation

/// Public extension providing access to raw localization data.
/// Intended for testing and debugging purposes — use these APIs to inspect
/// the current state of downloaded strings and plurals.
public extension CrowdinSDK {

    // MARK: - Strings

    /// All localization string keys available for the current localization,
    /// sorted alphabetically.
    static var allStringKeys: [String] {
        guard let strings = Localization.current?.provider.localStorage.strings else { return [] }
        return strings.keys.sorted()
    }

    /// Returns the raw (unformatted) localization string for the given key.
    /// For parametrized strings this value contains format specifiers such as
    /// `%@`, `%d`, `%f`, etc.
    ///
    /// - Parameter key: The localization key to look up.
    /// - Returns: The raw format string, or `nil` if the key is not found.
    static func rawString(forKey key: String) -> String? {
        return Localization.current?.provider.localStorage.strings[key]
    }

    // MARK: - Plurals

    /// All plural localization keys available for the current localization,
    /// sorted alphabetically.
    static var allPluralKeys: [String] {
        guard let plurals = Localization.current?.provider.localStorage.plurals as? [String: Any] else { return [] }
        return plurals.keys.sorted()
    }

    /// Returns all plural forms for the given key as a `[rule: formatString]`
    /// dictionary. Possible rule keys are `zero`, `one`, `two`, `few`, `many`,
    /// and `other` (a subset may be present depending on the language).
    ///
    /// - Parameter key: The plural localization key to look up.
    /// - Returns: A dictionary mapping plural rule names to their format strings.
    static func pluralForms(forKey key: String) -> [String: String] {
        guard
            let plurals = Localization.current?.provider.localStorage.plurals as? [String: Any],
            let pluralEntry = plurals[key] as? [AnyHashable: Any]
        else { return [:] }

        var forms: [String: String] = [:]
        for (k, value) in pluralEntry {
            guard
                let strKey = k as? String,
                strKey != "NSStringLocalizedFormatKey",
                let variableDict = value as? [String: String]
            else { continue }

            for (rule, format) in variableDict {
                guard
                    rule != "NSStringFormatSpecTypeKey",
                    rule != "NSStringFormatValueTypeKey"
                else { continue }
                forms[rule] = format
            }
        }
        return forms
    }
}
