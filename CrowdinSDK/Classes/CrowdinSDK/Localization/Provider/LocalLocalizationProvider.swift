//
//  LocalLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

class EmptyRemoteStorage: RemoteLocalizationStorage {
    var localization: String
    func fetchData(completion: @escaping LocalizationStorageCompletion) { }
    required init(localization: String) {
        self.localization = localization
    }
}

class InBundleLocalizationStorage: LocalLocalizationStorage {
    var additionalWord: String
    var localization: String {
        didSet {
            self.refresh()
        }
    }
    var localizations: [String] = Bundle.main.localizations
    var strings: [String: String] = [:]
    var plurals: [AnyHashable: Any] = [:]
    
    func fetchData(completion: @escaping LocalizationStorageCompletion) {
        self.refresh()
        completion(localizations, strings, plurals, [])
    }
    
    convenience init(additionalWord: String, localization: String) {
        self.init(localization: localization)
        self.additionalWord = additionalWord
    }
    
    required init(localization: String) {
        self.additionalWord = "cw"
        self.localization = localization
    }
    
    func refresh() {
        let extractor = LocalizationExtractor(localization: self.localization)
        self.plurals = self.addAdditionalWordTo(plurals: extractor.localizationPluralsDict)
        self.strings = self.addAdditionalWordTo(strings: extractor.localizationDict)
    }
    
    func addAdditionalWordTo(strings: [String: String]) -> [String: String] {
        var dict = strings
        for (key, value) in dict {
            dict[key] = value + "[\(localization)][\(additionalWord)]"
        }
        return dict
    }
    
    func addAdditionalWordTo(plurals: [AnyHashable: Any]) -> [AnyHashable: Any] {
        var dict = plurals
        dict.keys.forEach({ (key) in
            guard var localized = dict[key] as? [AnyHashable: Any] else { return }
            localized.keys.forEach({ (key1) in
                guard let strinKey = key1 as? String else { return }
                if strinKey == "NSStringLocalizedFormatKey" { return }
                guard var value = localized[strinKey] as? [String: String] else { return }
                value.keys.forEach({ (key) in
                    guard key != "NSStringFormatSpecTypeKey" else { return }
                    guard key != "NSStringFormatValueTypeKey" else { return }
                     // swiftlint:disable force_unwrapping
                    value[key] = value[key]! + "[\(localization)][\(additionalWord)]"
                })
                localized[strinKey] = value
            })
            dict[key] = localized
        })
        return dict
    }
}

public class LocalLocalizationProvider: BaseLocalizationProvider {
    public init() {
        let localization = Bundle.main.preferredLanguage
        let localStorage = InBundleLocalizationStorage(localization: localization)
        let remoteStorage = EmptyRemoteStorage(localization: localization)
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
    
    public init(additionalWord: String) {
        let localization = Bundle.main.preferredLanguage
        let localStorage = InBundleLocalizationStorage(additionalWord: additionalWord, localization: localization)
        let remoteStorage = EmptyRemoteStorage(localization: localization)
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
    
    public required init(localization: String, localStorage: LocalLocalizationStorage, remoteStorage: RemoteLocalizationStorage) {
        super.init(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
}
