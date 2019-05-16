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
    var pluralsMapping: [String: String] = [:]
    var stringsMapping: [String: String] = [:]
    var plurals: [AnyHashable: Any] = [:]
    
    init(strings: [String], plurals: [String], hash: String, sourceLanguage: String) {
        self.downloader = CrowdinMappingDownloader()
        self.downloader.download(strings: strings, plurals: plurals, with: hash, for: sourceLanguage) { (strings, plurals, _) in
            self.stringsMapping = strings ?? [:]
            self.plurals = plurals ?? [:]
            self.extractPluralsMapping()
        }
    }
    
    func stringLocalizationKey(for id: Int) -> String? {
        return stringsMapping.first(where: { Int($0.value) == id })?.key
    }
    
    func pluralLocalizationKey(for id: Int) -> String? {
        return pluralsMapping.first(where: { Int($0.value) == id })?.key
    }
    
    func idFor(string: String) -> Int? {
        guard let stringId = stringsMapping.first(where: { $0.key == string })?.value else { return nil }
        return Int(stringId)
    }
    
    func idFor(plural: String) -> Int? {
        guard let pluralId = pluralsMapping.first(where: { $0.key == plural })?.value else { return nil }
        return Int(pluralId)
    }
    
    func key(for id: Int) -> String? {
        return self.stringLocalizationKey(for: id) ?? self.pluralLocalizationKey(for: id)
    }
    
    func id(for string: String) -> Int? {
        return self.idFor(string: string) ?? self.idFor(plural: string)
    }
}

extension CrowdinMappingManager {
    func extractPluralsMapping() {
        pluralsMapping = [:]
        for (key, value) in plurals {
            guard let keyString = key as? String, let valueDict = value as? [AnyHashable: Any] else { continue }
            // Get main id for every key
            if let idString = valueDict["NSStringLocalizedFormatKey"] as? String {
                pluralsMapping[keyString] = idString
            }
            
            // Get id for every internal key if it exist.
            for (key, value) in valueDict {
                guard let keyString = key as? String, let valueDict = value as? [AnyHashable: Any] else { continue }
                if let idString = idFromDict(valueDict) {
                    pluralsMapping[keyString] = idString
                }
            }
        }
    }
    
    private enum Rules: String {
        case zero
        case one
        case two
        case few
        case many
        case other
        
        static var all: [Rules] {
            return [.zero, .one, .two, .few, .many, .other]
        }
    }
    
    func idFromDict(_ dict: [AnyHashable: Any]) -> String? {
        for rule in Rules.all {
            if let id = dict[rule.rawValue] as? String {
                return id
            }
        }
        return nil
    }
}
