//
//  LocalizationDataSource.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

protocol LocalizationDataSourceProtocol {
    func findKey(for string: String) -> String?
    func findValues(for string: String, with format: String) -> [Any]?
}


class StringsLocalizationDataSource: LocalizationDataSourceProtocol {
    var strings: [String: String]
    
    init(strings: [String: String]) {
        self.strings = strings
    }
    
    func findKey(for string: String) -> String? {
        for (key, value) in strings {
            if String.findMatch(for: value, with: string) { return key }
        }
        return nil
    }
    
    func findValues(for string: String, with format: String) -> [Any]? {
        return String.findValues(for: string, with: format)
    }
}

class PluralsLocalizationDataSource: LocalizationDataSourceProtocol {
    var plurals: [AnyHashable: Any]
    
    init(plurals: [AnyHashable: Any]) {
        self.plurals = plurals
    }
    func findKey(for string: String) -> String? {
        return findKeyValues(for: plurals, for: string).key
    }
    
    func findValues(for string: String, with format: String) -> [Any]? {
        return findKeyValues(for: plurals, for: string).values
    }
    
    func findKeyValues(for plurals: [AnyHashable: Any], for text: String) -> (key: String?, values: [Any]?) {
        for (key, plural) in plurals {
            guard let plural = plural as? [AnyHashable: Any] else { continue }
            for(key1, value) in plural {
                if key1 as! String == "NSStringLocalizedFormatKey" { continue }
                guard let value = value as? [String: String] else { continue }
                for (key2, formatedString) in value {
                    guard key2 != "NSStringFormatSpecTypeKey" else { continue }
                    guard key2 != "NSStringFormatValueTypeKey" else { continue }
                    // As plurals can be simple string then check whether it is equal to text. If not do the same as for formated string.
                    if formatedString == text { return (key as? String, nil) }
                    if String.findMatch(for: formatedString, with: text) {
                        let values = String.findValues(for: text, with: formatedString)
                        return (key as? String, values)
                    }
                }
            }
        }
        return (nil, nil)
    }
}

fileprivate extension String {
    static func findValues(for string: String, with format: String) -> [Any]? {
        let parts = FormatPart.formatParts(formatString: format)
        let matches = formatTypesRegEx.matches(in: format, options: [], range: NSRange(location: 0, length: format.count))
        guard matches.count > 0 else { return nil }
        let ranges = matches.compactMap({ $0.range })
        let nsStringValue = format as NSString
        let components = nsStringValue.splitBy(ranges: ranges)
        
        let nsStringText = string as NSString
        
        var valueRanges = [NSRange]()
        components.forEach({ valueRanges.append(nsStringText.range(of: $0)) })
        
        guard valueRanges.count > 0 else { return nil }
        
        let values = nsStringText.splitBy(ranges: valueRanges)
        
        guard values.count == parts.count else { return nil }
        
        var result = [Any]()
        
        for index in 0...parts.count - 1 {
            let part = parts[index]
            let value = values[index]
            guard let formatSpecifier = part.formatSpecifier else {
                result.append(value)
                continue
            }
            switch formatSpecifier {
            case .object: result.append(value)
            case .double: result.append(Double(value)!)
            case .int: result.append(Int(value)!)
            case .uInt: result.append(UInt(value)!)
            case .character: result.append(Character(value))
            case .cStringPointer: result.append(Double(value)!)
            case .voidPointer: result.append(Double(value)!)
            case .topType: result.append(value)
            }
        }
        
        return result
    }
}
