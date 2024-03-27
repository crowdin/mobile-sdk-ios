//
//  CrowdinXcstringsDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 16.03.2024.
//

import Foundation

public struct Localizations: Decodable {
    public let sourceLanguage: String
    public let version: String
    public let strings: [String: StringInfo]
}

public struct StringInfo: Decodable {
    public let extractionState: String?
    public let localizations: [String: StringLocalization]?
}

public struct StringLocalization: Decodable {
    public let stringUnit: StringUnit?
    public let variations: Variations?
    public let substitutions: [String: Substitution]?
}

public struct Substitution: Decodable {
    let argNum: Int
    let formatSpecifier: String
    let variations: Variations
}

public struct Variations: Decodable {
    let plural: [String: StringUnitWrapper]?
    // Skip for v 1.0
    //    let device: DeviceVariations?
}

// Skip for v 1.0
//public struct DeviceVariations: Decodable {
//    let variations: [String: StringUnitWrapper]?
//}

public struct StringUnitWrapper: Decodable {
    let stringUnit: StringUnit
}

public struct StringUnit: Decodable {
    public let state: String
    public let value: String
}


class XcstringsParser {
    enum Keys: String {
        case NSStringLocalizedFormatKey
        case NSStringFormatSpecTypeKey
        case NSStringFormatValueTypeKey
    }
    
    enum Strings: String {
        case NSStringPluralRuleType
    }
    
    static func parse(data: Data, localization: String) -> ([String: String]?, [AnyHashable: Any]?, Error?) {
        var strings: [String: String] = [:]
        var plurals: [String: Any] = [:]
        
        do {
            let localizations = try JSONDecoder().decode(Localizations.self, from: data)
            
            let localizationStrings = localizations.strings
            
            for (key, value) in localizationStrings {
                if let value = value.localizations?[localization] {
                    if let stringUnit = value.stringUnit, let substitutions = value.substitutions {
                        var dict = [String: Any]()
                        dict[Keys.NSStringLocalizedFormatKey.rawValue] = stringUnit.value
                        
                        for (key, substitution) in substitutions {
                            var pluralDict = Self.dictFor(substitution: substitution, with: substitutions)
                            pluralDict?[Keys.NSStringFormatSpecTypeKey.rawValue] = Strings.NSStringPluralRuleType.rawValue
                            pluralDict?[Keys.NSStringFormatValueTypeKey.rawValue] = substitution.formatSpecifier
                            dict[key] = pluralDict
                        }
                        
                        plurals[key] = dict
                    } else if let pluralVariation = value.variations?.plural {
                        var pluralDict = pluralVariation.mapValues({ $0.stringUnit.value })
                        pluralDict[Keys.NSStringFormatSpecTypeKey.rawValue] = Strings.NSStringPluralRuleType.rawValue
                        pluralDict[Keys.NSStringFormatValueTypeKey.rawValue] = pluralDict.values.map({ Self.formats(from: $0) }).filter({ $0.count > 0 }).first?.first ?? "u"
                        
                        var dict = [String: Any]()
                        dict[Keys.NSStringLocalizedFormatKey.rawValue] = "%#@\(key)@"
                        dict[key] = pluralDict
                        
                        plurals[key] = dict
                    } else if let stringUnit = value.stringUnit {
                        strings[key] = stringUnit.value
                    }
                }
            }
            
        } catch {
            return (nil, nil, error)
        }
        
        return (strings, plurals, nil)
    }
    
    static func dictFor(substitution: Substitution, with substitutions: [String: Substitution]) -> [String: Any]? {
        var dict = substitution.variations.plural?.mapValues({ $0.stringUnit.value }) ?? [:]
        
        for (key, value) in dict {
            for (key1, substitution) in substitutions {
                let refKey = "%#@\(key1)@"
                if value.contains(refKey) {
                    let parameteredKey = "%\(substitution.argNum)$#@\(key1)@"
                    dict[key] = value.replacingOccurrences(of: refKey, with: parameteredKey)
                }
            }
        }
        
        return dict
    }
    
    static func formats(from value: String) -> [String] {
        var specifiers: [String] = []
        var isSpecifier = false
        var currentSpecifier = ""
        
        for char in value {
            if char == "%" {
                isSpecifier = true
            } else if isSpecifier {
                if char.isLetter || char == "@" {
                    currentSpecifier.append(char)
                } else {
                    isSpecifier = false
                    if !currentSpecifier.isEmpty {
                        specifiers.append(currentSpecifier)
                        currentSpecifier = ""
                    }
                }
            }
        }
        
        return specifiers
    }
}

class CrowdinXcstringsDownloadOperation: CrowdinDownloadOperation {
    var timestamp: TimeInterval?
    var eTagStorage: AnyEtagStorage
    var completion: CrowdinJsonDownloadOperationCompletion? = nil
    let localization: String
    
    init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: CrowdinJsonDownloadOperationCompletion?) {
        self.localization = localization
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: localization)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }
    
    required init(filePath: String, localization: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        self.localization = localization
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: localization)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }
    
    override func main() {
        let etag = eTagStorage.etag(for: filePath)
        contentDeliveryAPI.getFileData(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] data, etag, error in
            guard let self = self else { return }
            self.eTagStorage.save(etag: etag, for: self.filePath)
            if let data {
                let parsed = XcstringsParser.parse(data: data, localization: localization)
                
                completion?(parsed.0, parsed.1, parsed.2)
                
                self.finish(with: parsed.2 != nil)
            } else {
                self.finish(with: error != nil)
            }
        }
    }
}
