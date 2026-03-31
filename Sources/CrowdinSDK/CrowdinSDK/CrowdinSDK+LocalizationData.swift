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
///
/// Key-lookup merges two sources in priority order:
///   1. **Remote strings** — translations downloaded from Crowdin and stored in
///      `LocalLocalizationStorage`. Present for translated languages.
///   2. **In-bundle strings** — values extracted from the app bundle's
///      `.strings` / `.stringsdict` files via `LocalLocalizationExtractor`.
///      Present for all languages (including the source language) and used as a
///      fallback so the testing screen always shows data.
public extension CrowdinSDK {

    // MARK: - Strings

    /// All localization string keys available for the current localization,
    /// sorted alphabetically. Merges remote downloaded keys with in-bundle keys.
    static var allStringKeys: [String] {
        guard let localization = Localization.current else { return [] }
        let remoteKeys = Set(localization.provider.localStorage.strings.keys)
        let bundleKeys = Set(localization.extractor.localizationDict.keys)
        return remoteKeys.union(bundleKeys).sorted()
    }

    /// Returns the raw (unformatted) localization string for the given key.
    /// For parametrized strings this value contains format specifiers such as
    /// `%@`, `%d`, `%f`, etc.
    /// Checks the remote downloaded strings first; falls back to the in-bundle
    /// string when no remote translation is available (e.g. source language).
    ///
    /// - Parameter key: The localization key to look up.
    /// - Returns: The raw format string, or `nil` if the key is not found in
    ///   either source.
    static func rawString(forKey key: String) -> String? {
        guard let localization = Localization.current else { return nil }
        return localization.provider.localStorage.strings[key]
            ?? localization.extractor.localizationDict[key]
    }

    // MARK: - Plurals

    /// All plural localization keys available for the current localization,
    /// sorted alphabetically. Merges remote downloaded keys with in-bundle keys.
    static var allPluralKeys: [String] {
        guard let localization = Localization.current else { return [] }
        let remoteKeys = (localization.provider.localStorage.plurals as? [String: Any])
            .map { Set($0.keys) } ?? []
        let bundleKeys = (localization.extractor.localizationPluralsDict as? [String: Any])
            .map { Set($0.keys) } ?? []
        return remoteKeys.union(bundleKeys).sorted()
    }

    /// Returns all plural forms for the given key as a `[rule: formatString]`
    /// dictionary. Possible rule keys are `zero`, `one`, `two`, `few`, `many`,
    /// and `other` (a subset may be present depending on the language).
    /// Checks remote downloaded plurals first; falls back to in-bundle plurals.
    ///
    /// - Parameter key: The plural localization key to look up.
    /// - Returns: A dictionary mapping plural rule names to their format strings.
    static func pluralForms(forKey key: String) -> [String: String] {
        guard let localization = Localization.current else { return [:] }

        // Try remote downloaded plurals first, then fall back to in-bundle.
        let remotePlurals = localization.provider.localStorage.plurals as? [String: Any]
        let bundlePlurals = localization.extractor.localizationPluralsDict as? [String: Any]
        let pluralEntry = (remotePlurals?[key] ?? bundlePlurals?[key]) as? [AnyHashable: Any]

        guard let entry = pluralEntry else { return [:] }
        return extractForms(from: entry)
    }

    // MARK: - Private helpers

    private static func extractForms(from pluralEntry: [AnyHashable: Any]) -> [String: String] {
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
