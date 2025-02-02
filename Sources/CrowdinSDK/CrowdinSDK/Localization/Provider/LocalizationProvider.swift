//
//  BaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

typealias LocalizationProviderCompletion = () -> Void
typealias LocalizationProviderError = (Error) -> Void

protocol LocalizationProviderProtocol {
    init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol)
    var localStorage: LocalLocalizationStorageProtocol { get }
    var remoteStorage: RemoteLocalizationStorageProtocol { get }

    var localization: String { get set }
    var localizations: [String] { get }

    func refreshLocalization()
    func refreshLocalization(completion: @escaping ((Error?) -> Void))

    func prepare(with completion: @escaping () -> Void)

    func deintegrate()
    func localizedString(for key: String) -> String?
    func key(for string: String) -> String?
    func values(for string: String, with format: String) -> [Any]?
    func set(string: String, for key: String)
}

class LocalizationProvider: NSObject, LocalizationProviderProtocol {
    private enum Strings: String {
        case Plurals
        case LocalizableStringsdict = "Localizable.stringsdict"
    }
    // Public
    var localization: String {
        didSet {
            self.refreshLocalization()
        }
    }
    var localizations: [String] { return remoteStorage.localizations }

    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol

    // Internal
    var strings: [String: String] { return localStorage.strings }
    var plurals: [AnyHashable: Any] { return localStorage.plurals }
    var pluralsFolder: FolderProtocol
    var pluralsBundle: DictionaryBundleProtocol?
    var stringsDataSource: LocalizationDataSourceProtocol
    var pluralsDataSource: LocalizationDataSourceProtocol

    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.pluralsFolder = Folder(path: CrowdinFolder.shared.path + String.pathDelimiter + Strings.Plurals.rawValue)
        self.stringsDataSource = StringsLocalizationDataSource(strings: [:])
        self.pluralsDataSource = PluralsLocalizationDataSource(plurals: [:])
        super.init()
        self.refreshLocalization()
    }

    func deintegrate() {
        try? CrowdinFolder.shared.remove()
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
        pluralsDataSource = PluralsLocalizationDataSource(plurals: plurals)
        setupPluralsBundle()
    }

    private
    func setupPluralsBundle() {
		pluralsBundle?.remove()
		pluralsFolder.directories.forEach { try? $0.remove() }
        let localizationFolderName = localStorage.localization + String.minus + UUID().uuidString
        pluralsBundle = DictionaryBundle(path: pluralsFolder.path + String.pathDelimiter + localizationFolderName, fileName: Strings.LocalizableStringsdict.rawValue, dictionary: self.plurals)
    }

    // Setup strings
    private
    func setupStrings() {
        self.stringsDataSource = StringsLocalizationDataSource(strings: strings)
    }

    private func saveLocalization(strings: [String: String]?, plurals: [AnyHashable: Any]?, for localization: String) {
        self.localStorage.saveLocalizaion(strings: strings, plurals: plurals, for: localization)
    }

    // Localization methods
    func localizedString(for key: String) -> String? {
        var string = self.strings[key]
        if string == nil {
			string = self.pluralsBundle?.bundle?.swizzled_LocalizedString(forKey: key, value: nil, table: nil)
            // Plurals localization works as default bundle localization. In case localized string for key is missing the key string will be returned. To prevent issues with localization where key equals value(for example for english language) we need to set nil here.
            if string == key {
                string = nil
            }
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
        self.setupStrings()
    }
}
