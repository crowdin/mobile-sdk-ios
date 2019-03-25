//
//  XMLDictionary+Extensions.swift
//  XMLDictionary
//
//  Created by Volker Bublitz on 23/02/2017.
//
//

import Foundation

enum XMLDictionaryKeys : String {
    case xmlDictionaryAttributesKey = "__attributes",
    xmlDictionaryCommentsKey = "__comments",
    xmlDictionaryTextKey = "__text",
    xmlDictionaryNodeNameKey = "__name",
    xmlDictionaryAttributePrefix = "_"
    
    func length() -> Int {
        return self.rawValue.count
    }
    func isArtificialNonAttributesKey() -> Bool {
        switch self {
        case .xmlDictionaryCommentsKey, .xmlDictionaryNodeNameKey, .xmlDictionaryTextKey:
            return true
        default:
            return false
        }
    }
}

public typealias XMLDictionary = Dictionary<String, Any>

public extension Dictionary where Key: ExpressibleByStringLiteral {
    
    public static func dictionaryWithXMLParser(parser:XMLParser) -> [String: Any]? {
        if let copy = XMLDictionaryParser.sharedInstance.copy() as? XMLDictionaryParser {
            return copy.dictionaryWithParser(parser: parser)
        }
        return nil
    }
    
    public static func dictionaryWithXMLData(xmlData:Data) -> [String: Any]? {
        if let copy = XMLDictionaryParser.sharedInstance.copy() as? XMLDictionaryParser {
            return copy.dictionaryWithData(data: xmlData)
        }
        return nil
    }
    
    public static func dictionaryWithXMLString(xmlString: String) -> [String: Any]? {
        if let copy = XMLDictionaryParser.sharedInstance.copy() as? XMLDictionaryParser {
            return copy.dictionaryWithString(string: xmlString)
        }
        return nil
    }
    
    public static func dictionaryWithXMLFile(xmlFilePath: String) -> [String: Any]? {
        if let copy = XMLDictionaryParser.sharedInstance.copy() as? XMLDictionaryParser {
            return copy.dictionaryWithFile(path: xmlFilePath)
        }
        return nil
    }
    
    public func attributeForKey(key:String) -> String? {
        return self.attributes()?[key]
    }
    
    public func attributes() -> [String : String]? {
        if let attributes = self[XMLDictionaryKeys.xmlDictionaryAttributesKey.rawValue as! Key] as? [String: String] {
            return attributes.count > 0 ? attributes : nil
        }
        else {
            let filteredDict = self.filter({ (key, value) -> Bool in
                if let kK = XMLDictionaryKeys(rawValue: String(describing: key)) {
                    return !kK.isArtificialNonAttributesKey()
                }
                return true
            })
            var result:[String : String] = [:]
            for (key, value) in filteredDict {
                guard let sValue = value as? String else {
                    continue
                }
                let sKey = String(describing: key)
                if sKey.hasPrefix(XMLDictionaryKeys.xmlDictionaryAttributePrefix.rawValue) {
                    let index = sKey.index(sKey.startIndex, offsetBy: XMLDictionaryKeys.xmlDictionaryAttributePrefix.length())
                    result[String(sKey.suffix(from: index))] = sValue
                }
            }
            return result.count > 0 ? result : nil
        }
    }
    
    public func childNodes() -> [String: Any]? {
        var result:[String:Any] = [:]
        self.forEach { (key, value) in
            let sKey = String(describing: key)
            if let _ = XMLDictionaryKeys(rawValue: sKey) {
                return
            }
            if sKey.hasPrefix(XMLDictionaryKeys.xmlDictionaryAttributePrefix.rawValue) {
                return
            }
            result[sKey] = value
        }
        return result.count > 0 ? result : nil
    }
    
    public func comments() -> [String]? {
        return self[XMLDictionaryKeys.xmlDictionaryCommentsKey.rawValue as! Key] as? [String]
    }
    
    public func nodeName() -> String? {
        return self[XMLDictionaryKeys.xmlDictionaryNodeNameKey.rawValue as! Key] as? String
    }
    
    public func innerText() -> Any? {
        let tmpResult = self[XMLDictionaryKeys.xmlDictionaryTextKey.rawValue as! Key]
        if let result = tmpResult as? [String] {
            return result.joined(separator: "\n")
        }
        return tmpResult
    }
    
    public func innerXML() -> String {
        var nodes:[String] = []
        nodes.append(contentsOf: self.comments()?.map({ (comment) -> String in
            return "<!--\(comment.xmlEncodedString())-->"
        }) ?? [])
        nodes.append(contentsOf: self.childNodes()?.map({ (key, value) -> String in
            return XMLDictionaryParser.XMLStringForNode(node: value, withNodeName: key)
        }) ?? [])
        if let text = self.innerText() as? String {
            nodes.append(text)
        }
        return nodes.joined(separator: "\n")
    }
    
    public func xmlString() -> String {
        let nodeName = self.nodeName()
        if self.count == 1 && nodeName == nil {
            return self.innerXML()
        }
        return XMLDictionaryParser.XMLStringForNode(node: self, withNodeName: nodeName ?? "root")
    }
    
    public func value(forKeyPath keyPath: String) -> Any? {
        let components = keyPath.components(separatedBy: ".")
        return self.value(forKeyComponents: components)
    }
    
    func value(forKeyComponents components: [String]) -> Any? {
        if components.count > 0 {
            let result = self.map({ keyEx, value -> Any? in
                let key = String(describing: keyEx)
                let object:Any? = (key == components[0] ? value : nil)
                if components.count > 1 {
                    let slice = components[1..<components.count]
                    let comps = Array<String>(slice)
                    if let mapValue = value as? [String : Any] {
                        return mapValue.value(forKeyComponents: comps)
                    }
                    if let mapValue = value as? [Any] {
                        return mapValue.value(forKeyComponents: comps)
                    }
                    return nil
                }
                return object
            }).filter({ (value) -> Bool in
                return value != nil
            })
            if result.count == 1 {
                return result.first!
            }
            return result
        }
        return nil
    }
    
    public func arrayValue(forKeyPath keyPath: String) -> [Any]? {
        if let value = self.value(forKeyPath: keyPath) {
            if let v = value as? [Any] {
                return v
            }
            return [value]
        }
        return nil
    }
    
    public func stringValue(forKeyPath keyPath: String) -> String? {
        let value = self.value(forKeyPath: keyPath)
        if let result = value as? String {
            return result
        }
        if let dict = value as? [String : Any] {
            return dict.innerText() as? String
        }
        if let arr = value as? [String] {
            return arr.first!
        }
        return nil
    }
    
    public func dictionaryValue(forKeyPath keyPath: String) -> [String : Any]? {
        let value = self.value(forKeyPath: keyPath)
        if let result = value as? [String : Any] {
            return result
        }
        if let arr = value as? [Any],
            let dict = arr.first as? [String: Any] {
            return dict
        }
        if let str = value as? String {
            return [XMLDictionaryKeys.xmlDictionaryTextKey.rawValue : str]
        }
        return nil
    }
    
}

extension Array {
    public func value(forKeyPath keyPath: String) -> Any? {
        let components = keyPath.components(separatedBy: ".")
        return self.value(forKeyComponents: components)
    }
    
    func value(forKeyComponents components: [String]) -> Any? {
        if components.count > 0 {
            guard let index = Int(components.first!) else {
                return nil
            }
            let value = self[index]
            if components.count > 1 {
                let slice = components[1..<components.count]
                let comps = Array<String>(slice)
                if let mapValue = value as? [String : Any] {
                    return mapValue.value(forKeyComponents: comps)
                }
                if let mapValue = value as? [Any] {
                    return mapValue.value(forKeyComponents: comps)
                }
                return nil
            }
            return value
        }
        return nil
    }
}

extension String {
    func xmlEncodedString() -> String {
        return self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "\'", with: "&apos;")
    }
}
