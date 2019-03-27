//
//  LocalLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

class EmptyRemoteStorage: RemoteLocalizationStorage {
    var localization: String
    func fetchData(completion: @escaping ([String], [String : String], [AnyHashable : Any]) -> Void) { }
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
    var strings: [String : String] = [:]
    var plurals: [AnyHashable : Any] = [:]
    
    
    func fetchData(completion: @escaping ([String], [String : String], [AnyHashable : Any]) -> Void) {
        self.refresh()
        completion(localizations, strings, plurals)
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
        dict.keys.forEach { (key) in
            dict[key] = dict[key]! + "[\(localization)][\(additionalWord)]"
        }
        return dict
    }
    
    func addAdditionalWordTo(plurals: [AnyHashable: Any]) -> [AnyHashable: Any] {
        var dict = plurals
        dict.keys.forEach({ (key) in
            var localized = dict[key] as! [AnyHashable: Any]
            localized.keys.forEach({ (key1) in
                if key1 as! String == "NSStringLocalizedFormatKey" { return }
                var value = localized[key1] as! [String: String]
                value.keys.forEach({ (key) in
                    guard key != "NSStringFormatSpecTypeKey" else { return }
                    guard key != "NSStringFormatValueTypeKey" else { return }
                    
                    value[key] = value[key]! + "[\(localization)][\(additionalWord)]"
                })
                localized[key1 as! String] = value
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
