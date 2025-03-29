//
//  CrowdinXcstringsDownloadOperation.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 16.03.2024.
//

import Foundation

typealias CrowdinDownloadOperationCompletion = ([String: String]?, [AnyHashable: Any]?, Error?) -> Void

public struct Localizations: Codable {
    public let sourceLanguage: String
    public let version: String
    public let strings: [String: StringInfo]
}

public struct StringInfo: Codable {
    public let extractionState: String?
    public let localizations: [String: StringLocalization]?
}

public struct StringLocalization: Codable {
    public let stringUnit: StringUnit?
    public let variations: Variations?
    public let substitutions: [String: Substitution]?
}

public struct Substitution: Codable {
    let argNum: Int
    let formatSpecifier: String
    let variations: Variations
}

public struct Variations: Codable {
    let plural: [String: StringUnitWrapper]?
    // Skip for v 1.0
    //    let device: DeviceVariations?
}

// Skip for v 1.0
// public struct DeviceVariations: Codable {
//    let variations: [String: StringUnitWrapper]?
// }

public struct StringUnitWrapper: Codable {
    let stringUnit: StringUnit
}

public struct StringUnit: Codable {
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

    static func parse(localizations: Localizations, localization: String) -> ([String: String]?, [AnyHashable: Any]?, Error?) {
        var strings: [String: String] = [:]
        var plurals: [String: Any] = [:]

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
        return (strings, plurals, nil)
    }

    static func parse(data: Data, localization: String) -> (strings: [String: String]?, plurals: [AnyHashable: Any]?, error: Error?) {
        do {
            let localizations = try JSONDecoder().decode(Localizations.self, from: data)

            return parse(localizations: localizations, localization: localization)
        } catch {
            return (nil, nil, error)
        }
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

class XCStringsStorage {
    private enum Strings: String {
        case XCStrings
    }

    // swiftlint:disable force_try
    static let folder = try! CrowdinFolder.shared.createFolder(with: Strings.XCStrings.rawValue)

    static func getFile(path: String) -> Data? {
        Data.read(from: folder.path + path)
    }

    static func saveFile(_ data: Data, path: String) {
        data.write(to: folder.path + path)
    }
}

class CrowdinXcstringsDownloadOperation: CrowdinDownloadOperation {
    var timestamp: TimeInterval?
    let eTagStorage: AnyEtagStorage
    var completion: CrowdinDownloadOperationCompletion? = nil
    let localization: String

    init(filePath: String, localization: String, xcstringsLanguage: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI, completion: CrowdinDownloadOperationCompletion?) {
        self.localization = localization
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: xcstringsLanguage)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
        self.completion = completion
    }

    required init(filePath: String, localization: String, xcstringsLanguage: String, timestamp: TimeInterval?, contentDeliveryAPI: CrowdinContentDeliveryAPI) {
        self.localization = localization
        self.timestamp = timestamp
        self.eTagStorage = FileEtagStorage(localization: xcstringsLanguage)
        super.init(filePath: filePath, contentDeliveryAPI: contentDeliveryAPI)
    }

    override func main() {
        let etag = eTagStorage.etag(for: filePath)
        contentDeliveryAPI.getFileData(filePath: filePath, etag: etag, timestamp: timestamp) { [weak self] data, etag, error in
            guard let self = self else { return }
            self.eTagStorage.save(etag: etag, for: self.filePath)
            if let data, data.count > 0 {
                XCStringsStorage.saveFile(data, path: self.filePath)
                let parsed = XcstringsParser.parse(data: data, localization: self.localization)
                self.completion?(parsed.strings, parsed.plurals, parsed.error)
                self.finish(with: parsed.error != nil)
            } else if let data = XCStringsStorage.getFile(path: self.filePath) {
                let parsed = XcstringsParser.parse(data: data, localization: self.localization)
                self.completion?(parsed.strings, parsed.plurals, parsed.error)
                self.finish(with: error != nil)
            } else {
                self.finish(with: error != nil)
            }
        }
    }
}
