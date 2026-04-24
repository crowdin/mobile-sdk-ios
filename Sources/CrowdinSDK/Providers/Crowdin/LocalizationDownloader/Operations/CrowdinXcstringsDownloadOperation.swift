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
    let argNum: Int?
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

                    // Build mapping of original substitution key -> sanitized key
                    var keyMapping = [String: String]()
                    for (subKey, _) in substitutions {
                        keyMapping[subKey] = Self.sanitizeFormatVariable(subKey)
                    }

                    // Replace key references in the format string value
                    var formatKeyValue = stringUnit.value
                    for (originalKey, sanitizedKey) in keyMapping {
                        formatKeyValue = formatKeyValue.replacingOccurrences(of: "%#@\(originalKey)@", with: "%#@\(sanitizedKey)@")
                    }
                    dict[Keys.NSStringLocalizedFormatKey.rawValue] = formatKeyValue

                    for (subKey, substitution) in substitutions {
                        var pluralDict = Self.dictFor(substitution: substitution, with: substitutions, keyMapping: keyMapping)
                        pluralDict?[Keys.NSStringFormatSpecTypeKey.rawValue] = Strings.NSStringPluralRuleType.rawValue
                        pluralDict?[Keys.NSStringFormatValueTypeKey.rawValue] = substitution.formatSpecifier
                        dict[keyMapping[subKey] ?? subKey] = pluralDict
                    }

                    plurals[key] = dict
                } else if let pluralVariation = value.variations?.plural {
                    var pluralDict = pluralVariation.mapValues({ $0.stringUnit.value })
                    pluralDict[Keys.NSStringFormatSpecTypeKey.rawValue] = Strings.NSStringPluralRuleType.rawValue
                    pluralDict[Keys.NSStringFormatValueTypeKey.rawValue] = pluralDict.values.map({ Self.formats(from: $0) }).filter({ $0.count > 0 }).first?.first ?? "u"

                    var dict = [String: Any]()
                    // Use a sanitized variable name to avoid issues with format specifiers in the key
                    let variableName = Self.sanitizeFormatVariable(key)
                    dict[Keys.NSStringLocalizedFormatKey.rawValue] = "%#@\(variableName)@"
                    dict[variableName] = pluralDict

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

    static func dictFor(substitution: Substitution, with substitutions: [String: Substitution], keyMapping: [String: String] = [:]) -> [String: Any]? {
        var dict = substitution.variations.plural?.mapValues({ $0.stringUnit.value }) ?? [:]

        // Replace the xcstrings design-time placeholder %arg with the actual
        // printf format specifier so the generated stringsdict entry matches what
        // Xcode would produce when compiling the xcstrings file. Without this,
        // Foundation sees "%a" (hex-float) instead of e.g. "%lld" and logs a
        // format-type mismatch warning when String(format:) is called.
        let argReplacement: String
        if let argNum = substitution.argNum {
            argReplacement = "%\(argNum)$\(substitution.formatSpecifier)"
        } else {
            argReplacement = "%\(substitution.formatSpecifier)"
        }
        for (key, value) in dict {
            dict[key] = value.replacingOccurrences(of: "%arg", with: argReplacement)
        }

        for (key, value) in dict {
            for (key1, substitution) in substitutions {
                let refKey = "%#@\(key1)@"
                if value.contains(refKey), let argNum = substitution.argNum {
                    let sanitizedKey1 = keyMapping[key1] ?? key1
                    let parameteredKey = "%\(argNum)$#@\(sanitizedKey1)@"
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

        // Handle a format specifier that appears at the end of the string
        if isSpecifier && !currentSpecifier.isEmpty {
            specifiers.append(currentSpecifier)
        }

        return specifiers
    }
    
    /// Encodes special characters so that different inputs map to unique, safe variable names.
    /// Allows only letters, digits, and underscores as-is; encodes any other character
    /// (including `%`, `@`, whitespace, punctuation) using its Unicode scalar value.
    /// - Parameter key: The original key name
    /// - Returns: A sanitized variable name safe to use in format strings
    static func sanitizeFormatVariable(_ key: String) -> String {
        var result = ""

        for character in key {
            if character.isLetter || character.isNumber || character == "_" {
                result.append(character)
            } else {
                for scalar in character.unicodeScalars {
                    let hex = String(format: "%02X", scalar.value)
                    result.append("_u\(hex)")
                }
            }
        }

        if result.isEmpty || result.first?.isNumber == true {
            return "var_" + result
        }

        return result
    }
}

class XCStringsStorage {
    private enum Strings: String {
        case XCStrings
    }

    static let folder: FolderProtocol = {
        do {
            return try CrowdinFolder.shared.createFolder(with: Strings.XCStrings.rawValue)
        } catch {
            CrowdinLogsCollector.shared.add(
                log: CrowdinLog(
                    type: .error,
                    message: "XCStringsStorage: Failed to create '\(Strings.XCStrings.rawValue)' folder. Falling back to root CrowdinFolder. Error: \(error.localizedDescription)"
                )
            )
            return CrowdinFolder.shared
        }
    }()

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
