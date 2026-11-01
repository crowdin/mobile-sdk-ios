//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

protocol LocalizationProviderProtocol {
    init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol)
    var localStorage: LocalLocalizationStorageProtocol { get }
    var remoteStorage: RemoteLocalizationStorageProtocol { get }

    var localization: String { get }
    var localizations: [String] { get }

    func refreshLocalization()
    func refreshLocalization(completion: @escaping ((Error?) -> Void))

    func prepare(with completion: @escaping () -> Void)

    func deintegrate()
    func setLocalization(_ localization: String, completion: @escaping ((Error?) -> Void))
    func localizedString(for key: String) -> String?
    func key(for string: String) -> String?
    func values(for string: String, with format: String) -> [Any]?
    func set(string: String, for key: String)
}

class LocalizationProvider: NSObject, LocalizationProviderProtocol {
    private enum Strings: String {
        case plurals = "Plurals"
        case localizableStringsdict = "Localizable.stringsdict"
    }
    // Public
    var localization: String
    var localizations: [String] { return remoteStorage.localizations }

    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol

    // Internal
    var strings: [String: String] { return localStorage.strings }
    var plurals: [AnyHashable: Any] { return localStorage.plurals }
    var pluralsFolder: FolderProtocol
    var pluralsBundle: DictionaryBundleProtocol?
    var stringsDataSource: AnyLocalizationDataSource<[String: String]>
    var pluralsDataSource: AnyLocalizationDataSource<[AnyHashable: Any]>

    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + Strings.plurals.rawValue)
        self.stringsDataSource = AnyLocalizationDataSource(StringsLocalizationDataSource(strings: [:]))
        self.pluralsDataSource = AnyLocalizationDataSource(PluralsLocalizationDataSource(plurals: [:]))
        super.init()
        self.refreshLocalization()
    }

    func deintegrate() {
        let isLocalStorageUsingRoot = (localStorage as? LocalLocalizationStorage)?.localizationFolder.path == CrowdinFolder.shared.path
        if !isLocalStorageUsingRoot {
            try? CrowdinFolder.shared.remove()
        }
        try? pluralsFolder.remove()
        pluralsBundle?.remove()
        remoteStorage.deintegrate()
        localStorage.deintegrate()
    }

    func refreshLocalization() {
        refreshLocalization(completion: { _ in })
    }

    func refreshLocalization(completion: @escaping ((Error?) -> Void)) {
        loadLocalLocalization { [weak self] _ in
            guard let self = self else { return }
            self.fetchRemoteLocalization(completion: completion)
        }
    }

    func prepare(with completion: @escaping () -> Void) {
        let shouldFetchLocalization = self.localizations.count == 0 // Remote storage doesn't contain any languages. Probably first run, no information about supported localizations.
        remoteStorage.prepare { [weak self] in
            guard let self = self else { return }
            if shouldFetchLocalization {
                self.refreshLocalization { _ in
                    completion()
                }
            } else {
                completion()
            }
        }
    }

    func setLocalization(_ localization: String, completion: @escaping ((Error?) -> Void)) {
        self.localization = localization
        self.refreshLocalization(completion: completion)
    }

    // Private method
    private func loadLocalLocalization(completion: @escaping ((Error?) -> Void)) {
        self.localStorage.localization = localization
        self.localStorage.fetchData(completion: { [weak self] localizations, localization, strings, plurals in
            guard let self = self else { return }
            guard localization == self.localization else { return }
            self.setup(with: localizations, strings: strings, plurals: plurals)
            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Localization fetched from local storage"))
            completion(nil)
        }, errorHandler: completion)
    }

    private func fetchRemoteLocalization(completion: @escaping ((Error?) -> Void)) {
        self.remoteStorage.localization = localization
        self.remoteStorage.fetchData(completion: { [weak self] localizations, localization, strings, plurals in
            guard let self = self else { return }

            guard localization == self.localization else {
                self.saveLocalization(strings: strings, plurals: plurals, for: localization)
                completion(nil)
                return
            }
            self.setup(with: localizations, strings: strings, plurals: plurals)
            completion(nil)
        }, errorHandler: completion)
    }

    private
    func setup(with localizations: [String]?, strings: [String: String]?, plurals: [AnyHashable: Any]?) {
        if let strings = strings {
            self.localStorage.strings.merge(with: strings)
        }
        if let plurals = plurals {
            self.localStorage.plurals.merge(with: plurals)
        }
        self.localStorage.save()
        self.setupStrings()
        self.setupPlurals()
    }

    // Setup plurals
    private
    func setupPlurals() {
        pluralsDataSource.update(with: plurals)
        setupPluralsBundle()
    }

    private
    func setupPluralsBundle() {
		pluralsBundle?.remove()
		pluralsFolder.directories.forEach { try? $0.remove() }
        let localizationFolderName = localStorage.localization + String.minus + UUID().uuidString
        pluralsBundle = DictionaryBundle(path: pluralsFolder.path + String.pathDelimiter + localizationFolderName,
                                        fileName: Strings.localizableStringsdict.rawValue,
                                        dictionary: PluralsFormatValidator.sanitized(self.plurals))
    }

    // Setup strings
    private
    func setupStrings() {
        stringsDataSource.update(with: strings)
    }

    private func saveLocalization(strings: [String: String]?, plurals: [AnyHashable: Any]?, for localization: String) {
        self.localStorage.saveLocalizaion(strings: strings, plurals: plurals, for: localization)
    }

    // Localization methods
    func localizedString(for key: String) -> String? {
        // Check plurals first - if a key has plurals defined, those take precedence over simple strings
        // This fixes the issue where keys exist in both .strings and .stringsdict files
        var string: String?
        if let bundle = self.pluralsBundle?.bundle {
            // Use swizzled_LocalizedString only when Bundle is swizzled (methods are exchanged),
            // otherwise call localizedString directly to avoid infinite recursion.
            if Bundle.isSwizzled {
                string = bundle.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
            } else {
                string = bundle.localizedString(forKey: key, value: nil, table: nil)
            }
            // Plurals localization works as default bundle localization.
            // In case localized string for key is missing the key string will be returned.
            // To prevent issues with localization where key equals value(for example for english language) we need to set nil here.
            if string == key {
                string = nil
            }
        }
        
        // If no plural exists, fall back to simple strings
        if string == nil {
            string = self.strings[key]
        }
        return string
    }

    func key(for string: String) -> String? {
        var key = stringsDataSource.findKey(for: string)
        guard key == nil else { return key }
        key = pluralsDataSource.findKey(for: string)
        return key
    }

    func values(for string: String, with format: String) -> [Any]? {
        var values = self.stringsDataSource.findValues(for: string, with: format)
        if values == nil {
            values = self.pluralsDataSource.findValues(for: string, with: format)
        }
        return values
    }

    func set(string: String, for key: String) {
        self.localStorage.strings[key] = string
        stringsDataSource.update(with: self.strings)
    }
}

/// Guards the stringsdict path against CWE-134.
///
/// A plural key resolves to its `NSStringLocalizedFormatKey` (e.g. `%#@n@`), and
/// `String(format:)` then expands it from the downloaded plural variants. The
/// format-string check in `String.cw_safeFormat` only sees the former, so the
/// variants have to be vetted before they reach the plurals bundle: an entry
/// whose variants read more arguments than its format key declares (or read
/// them as the wrong type) would otherwise let a translator walk past the
/// argument list. Unsafe entries are dropped, so the lookup falls back to the
/// plain string or the app's bundled localization.
enum PluralsFormatValidator {
    private static let formatKey = "NSStringLocalizedFormatKey"
    private static let valueTypeKey = "NSStringFormatValueTypeKey"
    private static let specTypeKey = "NSStringFormatSpecTypeKey"

    /// What `NSStringFormatValueTypeKey` may hold: one numeric conversion with an optional length modifier.
    private static let valueTypeRegEx = try? NSRegularExpression(pattern: "^(?:hh|h|ll|l|q|L|z|t|j)?[dDiuUoOxXaAeEfFgG]$")

    static func sanitized(_ plurals: [AnyHashable: Any]) -> [AnyHashable: Any] {
        return plurals.filter { isSafe(entry: $0.value) }
    }

    static func isSafe(entry: Any) -> Bool {
        guard let dictionary = entry as? [AnyHashable: Any],
              let format = dictionary[formatKey] as? String,
              let formatParts = FormatPart.formatParts(formatString: format) else { return false }
        // The runtime check requires the format key's argument count to be covered by the caller's
        // arguments, so variants may read at most that many.
        return dictionary.allSatisfy { key, value in
            if let key = key as? String, key == formatKey { return true }
            guard let variable = value as? [AnyHashable: Any] else { return true }
            return isSafe(variable: variable, argumentLimit: formatParts.count)
        }
    }

    private static func isSafe(variable: [AnyHashable: Any], argumentLimit: Int) -> Bool {
        return variable.allSatisfy { key, value in
            if let key = key as? String, key == specTypeKey { return true }
            if let key = key as? String, key == valueTypeKey {
                guard let valueType = value as? String, let regEx = valueTypeRegEx else { return false }
                return regEx.firstMatch(in: valueType, options: [], range: NSRange(location: 0, length: (valueType as NSString).length)) != nil
            }
            if let nested = value as? [AnyHashable: Any] {
                return isSafe(variable: nested, argumentLimit: argumentLimit)
            }
            guard let variant = value as? String else { return true }
            return isSafe(variant: variant, argumentLimit: argumentLimit)
        }
    }

    /// A variant formats the variable's own number, so it may hold at most one numeric specifier
    /// (plus references to other variables) and must not reach beyond the format key's arguments.
    private static func isSafe(variant: String, argumentLimit: Int) -> Bool {
        guard let parts = FormatPart.formatParts(formatString: variant), parts.count <= argumentLimit else { return false }
        let specifiers = parts.compactMap { $0.formatSpecifier }.filter { $0 != .topType }
        guard specifiers.count <= 1 else { return false }
        return specifiers.allSatisfy { $0 == .int || $0 == .uInt || $0 == .double }
    }
}
