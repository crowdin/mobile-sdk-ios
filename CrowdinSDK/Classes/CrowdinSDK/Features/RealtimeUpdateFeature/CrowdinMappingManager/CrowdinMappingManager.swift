//
//  CrowdinMappingManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/6/19.
//

import Foundation

protocol CrowdinMappingManagerProtocol {
    func stringLocalizationKey(for id: Int) -> String?
    func pluralLocalizationKey(for id: Int) -> String?
    
    func idFor(string: String) -> Int?
    func idFor(plural: String) -> Int?
    
    func id(for string: String) -> Int?
    func key(for id: Int) -> String?
}

class CrowdinMappingManager: CrowdinMappingManagerProtocol {
    let downloader: CrowdinMappingDownloader
    var strings: [String: String] = [:]
    var plurals: [AnyHashable: Any] = [:]
    
    init(strings: [String], plurals: [String], hash: String, sourceLanguage: String) {
        self.downloader = CrowdinMappingDownloader()
        self.downloader.download(strings: strings, plurals: plurals, with: hash, for: sourceLanguage) { (strings, plurals, errors) in
            self.strings = strings ?? [:]
            self.plurals = plurals ?? [:]
        }
    }
    
    func stringLocalizationKey(for id: Int) -> String? {
        return strings.first(where: { Int($0.value) == id })?.key
    }
    
    func pluralLocalizationKey(for id: Int) -> String? {
        let key: String? = nil
        return key
    }
    
    func idFor(string: String) -> Int? {
        guard let stringId = strings.first(where: { $0.key == string })?.value else { return nil }
        return Int(stringId)
    }
    
    func idFor(plural: String) -> Int? {
        let id: Int? = nil
        return id
    }
    
    func key(for id: Int) -> String? {
        return self.stringLocalizationKey(for: id) ?? self.pluralLocalizationKey(for: id)
    }
    
    func id(for string: String) -> Int? {
        return self.idFor(string: string) ?? self.idFor(plural: string)
    }
}
