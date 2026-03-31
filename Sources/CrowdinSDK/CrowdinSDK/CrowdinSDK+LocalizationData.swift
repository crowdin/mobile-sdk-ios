//
//  CrowdinSDK+LocalizationData.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 31.03.2026.
//

import Foundation

// MARK: - LocalizationDataSource

/// Selects which backing store to use when querying localization data.
///
/// - `crowdin`: Translations downloaded from Crowdin and stored in
///   `LocalLocalizationStorage` (`provider.localStorage`). Only present for
///   languages that have been downloaded; empty for the source language unless
///   it has also been fetched from Crowdin.
/// - `bundle`: Values extracted from the app bundle's `.strings` /
///   `.stringsdict` files via `LocalLocalizationExtractor`. Present for all
///   languages including the source language.
public enum LocalizationDataSource {
    case crowdin
    case bundle
}

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
    ///
    /// Both `localStorage.plurals` and `extractor.localizationPluralsDict` are
    /// `[AnyHashable: Any]`. Keys from a plist-loaded `NSDictionary` are
    /// `NSString`, which Swift wraps in `AnyHashable` — a dictionary-level cast
    /// to `[String: Any]` fails for those even when every key is a string.
    /// We therefore extract keys via `compactMap { $0 as? String }` to handle
    /// both pure-Swift `[String: Any]` and plist-sourced dictionaries safely.
    static var allPluralKeys: [String] {
        guard let localization = Localization.current else { return [] }
        let remoteKeys = Set(localization.provider.localStorage.plurals.keys.compactMap { $0 as? String })
        let bundleKeys = Set(localization.extractor.localizationPluralsDict.keys.compactMap { $0 as? String })
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

        // Both dicts are [AnyHashable: Any]; subscript with String works because
        // AnyHashable(NSString("key")) == AnyHashable(String("key")).
        let remotePlurals = localization.provider.localStorage.plurals
        let bundlePlurals = localization.extractor.localizationPluralsDict

        let pluralEntry = (remotePlurals[key] ?? bundlePlurals[key]) as? [AnyHashable: Any]

        guard let entry = pluralEntry else { return [:] }
        return extractForms(from: entry)
    }

    // MARK: - Source-specific Strings

    /// All localization string keys available from the specified data source,
    /// sorted alphabetically.
    ///
    /// - Parameter source: Whether to query Crowdin (remote) or in-bundle data.
    static func allStringKeys(from source: LocalizationDataSource) -> [String] {
        guard let localization = Localization.current else { return [] }
        switch source {
        case .crowdin:
            return localization.provider.localStorage.strings.keys.sorted()
        case .bundle:
            return localization.extractor.localizationDict.keys.sorted()
        }
    }

    /// Returns the raw (unformatted) localization string for the given key from
    /// the specified data source.
    ///
    /// - Parameters:
    ///   - key:    The localization key to look up.
    ///   - source: Whether to query Crowdin (remote) or in-bundle data.
    /// - Returns: The raw format string, or `nil` if the key is not found in
    ///   the selected source.
    static func rawString(forKey key: String, from source: LocalizationDataSource) -> String? {
        guard let localization = Localization.current else { return nil }
        switch source {
        case .crowdin:
            return localization.provider.localStorage.strings[key]
        case .bundle:
            return localization.extractor.localizationDict[key]
        }
    }

    // MARK: - Source-specific Plurals

    /// All plural localization keys available from the specified data source,
    /// sorted alphabetically.
    ///
    /// - Parameter source: Whether to query Crowdin (remote) or in-bundle data.
    static func allPluralKeys(from source: LocalizationDataSource) -> [String] {
        guard let localization = Localization.current else { return [] }
        switch source {
        case .crowdin:
            return localization.provider.localStorage.plurals.keys
                .compactMap { $0 as? String }
                .sorted()
        case .bundle:
            return localization.extractor.localizationPluralsDict.keys
                .compactMap { $0 as? String }
                .sorted()
        }
    }

    /// Returns all plural forms for the given key from the specified data
    /// source as a `[rule: formatString]` dictionary.
    ///
    /// - Parameters:
    ///   - key:    The plural localization key to look up.
    ///   - source: Whether to query Crowdin (remote) or in-bundle data.
    /// - Returns: A dictionary mapping plural rule names to their format strings.
    static func pluralForms(forKey key: String, from source: LocalizationDataSource) -> [String: String] {
        guard let localization = Localization.current else { return [:] }
        let dict: [AnyHashable: Any]
        switch source {
        case .crowdin:
            dict = localization.provider.localStorage.plurals
        case .bundle:
            dict = localization.extractor.localizationPluralsDict
        }
        guard let entry = dict[key] as? [AnyHashable: Any] else { return [:] }
        return extractForms(from: entry)
    }

    // MARK: - Private helpers

    /// Walks a single plural entry (one key in a stringsdict plist) and returns
    /// a flat `[rule: formatString]` mapping, skipping stringsdict meta-keys.
    private static func extractForms(from pluralEntry: [AnyHashable: Any]) -> [String: String] {
        var forms: [String: String] = [:]
        for (k, value) in pluralEntry {
            guard
                let strKey = k as? String,
                strKey != "NSStringLocalizedFormatKey"
            else { continue }

            // Each variable sub-dict may use String or NSString keys.
            // Build a [String: String] view regardless of the concrete key type.
            let variableDict: [String: String]
            if let direct = value as? [String: String] {
                variableDict = direct
            } else if let anyHashable = value as? [AnyHashable: Any] {
                variableDict = anyHashable.reduce(into: [:]) { result, pair in
                    if let k = pair.key as? String, let v = pair.value as? String {
                        result[k] = v
                    }
                }
            } else {
                continue
            }

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
