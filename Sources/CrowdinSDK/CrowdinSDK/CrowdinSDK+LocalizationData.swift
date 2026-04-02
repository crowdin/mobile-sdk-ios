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

// MARK: - CrowdinPluralEntry

/// Structured representation of a single stringsdict plural entry.
///
/// A stringsdict key can reference one or more **variables**, each with its own
/// set of CLDR plural forms. Simple keys (e.g. `reminders_count`) have a single
/// variable. Complex keys (e.g. `files_in_folders_count`) have two or more
/// independent variables, each driven by a separate integer argument. Nested
/// keys (e.g. `tasks_completed_in_days`) have one variable whose forms embed
/// a reference to a second variable (`%#@days@`).
///
/// Variables are ordered by their appearance in `formatKey`, which determines
/// the argument order for `String.localizedStringWithFormat`.
public struct CrowdinPluralEntry {

    /// A single plural variable within a stringsdict entry.
    public struct Variable {
        /// The variable name as it appears between `%#@` and `@` in the format key.
        public let name: String
        /// CLDR plural rule → format string mapping.
        /// Possible keys: `zero`, `one`, `two`, `few`, `many`, `other`.
        public let forms: [String: String]
    }

    /// The `NSStringLocalizedFormatKey` value (e.g. `%#@reminders@` or
    /// `%1$#@files@ in %2$#@folders@`). Pass this to `String(format:arguments:)`
    /// together with one integer per variable.
    public let formatKey: String

    /// All plural variables, ordered by their position in `formatKey`.
    public let variables: [Variable]

    /// `true` when this entry has exactly one variable (most common case).
    public var isSimple: Bool { variables.count == 1 }

    /// `true` when this entry has two or more independent variables.
    public var isComplex: Bool { variables.count > 1 }
}

// MARK: - Public extension

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
    /// - `.crowdin`: Merges remote (Crowdin) keys with in-bundle keys so the
    ///   list is never empty even before a download completes.
    /// - `.bundle`: Only keys found in the app bundle's `.strings` files.
    static func allStringKeys(from source: LocalizationDataSource) -> [String] {
        guard let localization = Localization.current else { return [] }
        switch source {
        case .crowdin:
            let remoteKeys = Set(localization.provider.localStorage.strings.keys)
            let bundleKeys = Set(localization.extractor.localizationDict.keys)
            return remoteKeys.union(bundleKeys).sorted()
        case .bundle:
            return localization.extractor.localizationDict.keys.sorted()
        }
    }

    /// Returns the raw (unformatted) localization string for the given key from
    /// the specified data source.
    ///
    /// - `.crowdin`: Remote value when available, falling back to the in-bundle value.
    /// - `.bundle`: In-bundle value only.
    static func rawString(forKey key: String, from source: LocalizationDataSource) -> String? {
        guard let localization = Localization.current else { return nil }
        switch source {
        case .crowdin:
            return localization.provider.localStorage.strings[key]
                ?? localization.extractor.localizationDict[key]
        case .bundle:
            return localization.extractor.localizationDict[key]
        }
    }

    // MARK: - Source-specific Plurals

    /// All plural localization keys available from the specified data source,
    /// sorted alphabetically.
    ///
    /// - `.crowdin`: Only keys present in data downloaded from Crowdin
    ///   (`localStorage.plurals`). Returns an empty list when Crowdin has not
    ///   downloaded any plural data (most distributions ship only `.strings`).
    /// - `.bundle`: Only keys found in the app bundle's `.stringsdict` files.
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

    /// Returns all plural forms for the given key from the specified data source
    /// as a flat `[rule: formatString]` dictionary (merges all variables).
    ///
    /// - `.crowdin`: Remote (Crowdin-downloaded) forms only. Returns `[:]` when
    ///   Crowdin has not downloaded plural data for this key.
    /// - `.bundle`: In-bundle forms only.
    static func pluralForms(forKey key: String, from source: LocalizationDataSource) -> [String: String] {
        guard let localization = Localization.current else { return [:] }
        switch source {
        case .crowdin:
            guard let entry = localization.provider.localStorage.plurals[key] as? [AnyHashable: Any] else { return [:] }
            return extractForms(from: entry)
        case .bundle:
            guard let entry = localization.extractor.localizationPluralsDict[key] as? [AnyHashable: Any] else { return [:] }
            return extractForms(from: entry)
        }
    }

    // MARK: - Remote data availability

    /// Returns `true` if Crowdin has downloaded a translation for the given
    /// string key (i.e. the value exists in `localStorage.strings`).
    ///
    /// Returns `false` for source-language keys that are only available in the
    /// in-bundle extractor.
    static func hasCrowdinString(forKey key: String) -> Bool {
        guard let localization = Localization.current else { return false }
        return localization.provider.localStorage.strings[key] != nil
    }

    /// Returns `true` if Crowdin has downloaded plural forms for the given key
    /// (i.e. the entry exists and is non-empty in `localStorage.plurals`).
    ///
    /// Most Crowdin distributions ship only `.strings` files — in that case
    /// this will return `false` even though bundle plurals exist.
    static func hasCrowdinPlural(forKey key: String) -> Bool {
        guard let localization = Localization.current else { return false }
        guard let entry = localization.provider.localStorage.plurals[key] as? [AnyHashable: Any] else { return false }
        return !entry.isEmpty
    }

    // MARK: - Structured Plural Entry

    /// Returns the structured `CrowdinPluralEntry` for the given key and source,
    /// exposing per-variable forms and the `NSStringLocalizedFormatKey` needed
    /// to drive the system's plural resolution.
    ///
    /// Returns `nil` if the key does not exist in the selected source or if the
    /// plist data cannot be parsed.
    static func pluralEntry(forKey key: String, from source: LocalizationDataSource) -> CrowdinPluralEntry? {
        guard let localization = Localization.current else { return nil }
        let rawEntry: [AnyHashable: Any]?
        switch source {
        case .crowdin:
            // Strict: only remote data. Returns nil when Crowdin has not
            // downloaded plural data, keeping the two sources clearly separated.
            rawEntry = localization.provider.localStorage.plurals[key] as? [AnyHashable: Any]
        case .bundle:
            rawEntry = localization.extractor.localizationPluralsDict[key] as? [AnyHashable: Any]
        }
        guard let entry = rawEntry else { return nil }
        return parsePluralEntry(from: entry)
    }

    // MARK: - Private helpers

    /// Builds a `CrowdinPluralEntry` from a raw stringsdict plist dictionary.
    private static func parsePluralEntry(from dict: [AnyHashable: Any]) -> CrowdinPluralEntry? {
        guard let formatKey = dict[AnyHashable("NSStringLocalizedFormatKey")] as? String else { return nil }

        // Collect variable sub-dicts (every key except NSStringLocalizedFormatKey)
        var variableDicts: [String: [AnyHashable: Any]] = [:]
        for (k, v) in dict {
            guard let name = k as? String,
                  name != "NSStringLocalizedFormatKey",
                  let subDict = v as? [AnyHashable: Any] else { continue }
            variableDicts[name] = subDict
        }

        // Determine variable order from format key (e.g. %#@files@ before %#@folders@)
        let orderedNames = extractVariableOrder(from: formatKey)

        var variables: [CrowdinPluralEntry.Variable] = []
        var seen = Set<String>()

        for name in orderedNames where !seen.contains(name) {
            if let subDict = variableDicts[name] {
                variables.append(.init(name: name, forms: extractVariableForms(from: subDict)))
                seen.insert(name)
            }
        }
        // Also add any variables not directly referenced in the top-level format key
        // (e.g. nested variables embedded inside another variable's forms)
        for (name, subDict) in variableDicts where !seen.contains(name) {
            variables.append(.init(name: name, forms: extractVariableForms(from: subDict)))
            seen.insert(name)
        }

        guard !variables.isEmpty else { return nil }
        return CrowdinPluralEntry(formatKey: formatKey, variables: variables)
    }

    /// Returns variable names in the order they appear in the stringsdict format key.
    /// Handles both `%#@varName@` and positional `%1$#@varName@` specifiers.
    private static func extractVariableOrder(from formatKey: String) -> [String] {
        let pattern = "%(?:\\d+\\$)?#@(\\w+)@"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = formatKey as NSString
        let matches = regex.matches(in: formatKey, range: NSRange(location: 0, length: ns.length))
        var names: [String] = []
        var seen = Set<String>()
        for match in matches {
            let range = match.range(at: 1)
            guard range.location != NSNotFound else { continue }
            let name = ns.substring(with: range)
            if !seen.contains(name) { names.append(name); seen.insert(name) }
        }
        return names
    }

    /// Extracts CLDR plural forms from a single variable's sub-dict,
    /// skipping stringsdict metadata keys.
    private static func extractVariableForms(from dict: [AnyHashable: Any]) -> [String: String] {
        var forms: [String: String] = [:]
        for (k, v) in dict {
            guard let rule = k as? String,
                  rule != "NSStringFormatSpecTypeKey",
                  rule != "NSStringFormatValueTypeKey",
                  let format = v as? String else { continue }
            forms[rule] = format
        }
        return forms
    }

    /// Walks a single plural entry (one key in a stringsdict plist) and returns
    /// a **flat** `[rule: formatString]` mapping across all variables,
    /// skipping stringsdict meta-keys.
    private static func extractForms(from pluralEntry: [AnyHashable: Any]) -> [String: String] {
        var forms: [String: String] = [:]
        for (k, value) in pluralEntry {
            guard let strKey = k as? String,
                  strKey != "NSStringLocalizedFormatKey" else { continue }

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
                guard rule != "NSStringFormatSpecTypeKey",
                      rule != "NSStringFormatValueTypeKey" else { continue }
                forms[rule] = format
            }
        }
        return forms
    }
}
