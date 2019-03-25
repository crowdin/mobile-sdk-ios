//
//  XMLDictionaryParser.swift
//  XMLDictionary
//
//  Created by Volker Bublitz on 23/02/2017.
//
//
#if os(OSX) || os(iOS)
    import Darwin
#elseif os(Linux) || CYGWIN
    import Glibc
#endif

import Foundation

public enum XMLDictionaryAttributesMode {
    case xmlDictionaryAttributesModePrefixed, xmlDictionaryAttributesModeDictionary,
    xmlDictionaryAttributesModeUnprefixed, xmlDictionaryAttributesModeDiscard
}

public enum XMLDictionaryNodeNameMode {
    case xmlDictionaryNodeNameModeRootOnly, xmlDictionaryNodeNameModeAlways, xmlDictionaryNodeNameModeNever
}

public class XMLDictionaryParser : NSObject, XMLParserDelegate, NSCopying {
    
    public var collapseTextNodes:Bool = true
    public var stripEmptyNodes:Bool = true
    public var trimWhiteSpace:Bool = true
    public var alwaysUseArrays:Bool = false
    public var preserveComments:Bool = false
    public var wrapRootNode:Bool = false
    
    public var attributesMode:XMLDictionaryAttributesMode = .xmlDictionaryAttributesModePrefixed
    public var nodeNameMode:XMLDictionaryNodeNameMode = .xmlDictionaryNodeNameModeRootOnly
    
    private var root:XMLTupleHolder?
    private var stack:[XMLTupleHolder]?
    private var text:String?
    
    public static let sharedInstance = XMLDictionaryParser()
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = XMLDictionaryParser()
        copy.collapseTextNodes = self.collapseTextNodes
        copy.stripEmptyNodes = self.stripEmptyNodes
        copy.trimWhiteSpace = self.trimWhiteSpace
        copy.alwaysUseArrays = self.alwaysUseArrays
        copy.preserveComments = self.preserveComments
        copy.wrapRootNode = self.wrapRootNode
        copy.attributesMode = self.attributesMode
        copy.nodeNameMode = self.nodeNameMode
        return copy
    }
    
    public func dictionaryWithParser(parser:XMLParser) -> [String : Any]? {
        parser.delegate = self
        let _ = parser.parse()
        let result = root
        root = nil
        stack = nil
        text = nil
        return result?.resolvedDictionary()
    }
    
    public func dictionaryWithData(data:Data) -> [String : Any]? {
        return self.dictionaryWithParser(parser: XMLParser(data: data))
    }
    
    public func dictionaryWithString(string:String) -> [String : Any]? {
        return self.dictionaryWithData(data: string.data(using: .utf8)!)
    }
    
    public func dictionaryWithFile(path:String) -> [String : Any]? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return self.dictionaryWithData(data: data)
        }
        catch {
            return nil
        }
    }
    
    func endText() {
        if (trimWhiteSpace) {
            text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        if let processingText = text, processingText.count > 0 {
            if let top = stack?.last {
                if let existing = top[XMLDictionaryKeys.xmlDictionaryTextKey.rawValue] {
                    if let e = existing as? XMLArrayHolder {
                        e.append(processingText)
                    }
                    else {
                        top[XMLDictionaryKeys.xmlDictionaryTextKey.rawValue] = XMLArrayHolder([existing, processingText])
                    }
                }
                else {
                    top[XMLDictionaryKeys.xmlDictionaryTextKey.rawValue] = processingText
                }
            }
        }
        text = nil
    }
    
    func addText(appendingText: String) {
        text = (text ?? "") + appendingText
    }
    
#if os(Linux)
    
    public func parserDidStartDocument(_ parser: XMLParser) { }
    public func parserDidEndDocument(_ parser: XMLParser) { }
    
    public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) { }
    
    public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) { }
    
    public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) { }
    
    public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) { }
    
    public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) { }
    
    public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) { }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.parserD(parser, didStartElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.parserD(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
    }
    
    public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) { }
    
    public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) { }
    
    
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) { }
    
    public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) { }
    
    
    
    public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? { return nil }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Foundation.NSError) { }
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Foundation.NSError) { }
    
#else
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.parserD(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
    }
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.parserD(parser, didStartElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
    }
#endif
    
    public func parserD(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.endText()
        let node = XMLTupleHolder([:])
        
        switch nodeNameMode {
        case .xmlDictionaryNodeNameModeRootOnly:
            if root == nil {
                node[XMLDictionaryKeys.xmlDictionaryNodeNameKey.rawValue] = elementName
            }
            break
        case .xmlDictionaryNodeNameModeAlways:
            node[XMLDictionaryKeys.xmlDictionaryNodeNameKey.rawValue] = elementName
            break
        case .xmlDictionaryNodeNameModeNever:
            break
        }
        
        if attributeDict.count > 0 {
            switch attributesMode {
            case .xmlDictionaryAttributesModePrefixed:
                attributeDict.forEach({ (key, value) in
                    node[XMLDictionaryKeys.xmlDictionaryAttributePrefix.rawValue + key] = value
                })
                break
            case .xmlDictionaryAttributesModeDictionary:
                node[XMLDictionaryKeys.xmlDictionaryAttributesKey.rawValue] = attributeDict
                break
            case .xmlDictionaryAttributesModeUnprefixed:
                attributeDict.forEach({ (key, value) in
                    node[key] = value
                })
                break
            case .xmlDictionaryAttributesModeDiscard:
                break
            }
        }
        
        guard let _ = root else {
            root = node
            stack = [node]
            if wrapRootNode {
                root = XMLTupleHolder([elementName : node])
                stack?.insert(root!, at: 0)
            }
            return
        }
        
        if let top = stack?.last {
            if let existing = top[elementName] {
                if let e = existing as? XMLArrayHolder {
                    e.append(node)
                }
                else {
                    top[elementName] = XMLArrayHolder([existing, node])
                }
            }
            else {
                if alwaysUseArrays {
                    top[elementName] = XMLArrayHolder([node])
                }
                else {
                    top[elementName] = node
                }
            }
        }
        stack?.append(node)
    }
    
    public func parserD(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.endText()
        if let top = stack?.popLast() {
            if (top.dict.attributes() == nil && top.dict.childNodes() == nil && top.dict.comments() == nil) {
                    let nextTop:XMLTupleHolder = stack?.last ?? XMLTupleHolder([:])
                    if let nodeName = self.nameForNode(node: top, inParentNode: nextTop) {
                        let parentNode = nextTop[nodeName]
                        if let innerText = top.dict.innerText() {
                            if collapseTextNodes {
                                if let parentArray = parentNode as? XMLArrayHolder {
                                    parentArray[parentArray.count - 1] = innerText
                                }
                                else {
                                    nextTop[nodeName] = innerText
                                }
                            }
                        }
                        else {
                            if stripEmptyNodes {
                                if let parentArray = parentNode as? XMLArrayHolder {
                                    parentArray.removeLast()
                                }
                                else {
                                    nextTop[nodeName] = nil
                                }
                            }
                            else if !collapseTextNodes {
                                top[XMLDictionaryKeys.xmlDictionaryTextKey.rawValue] = ""
                            }
                        }
                        if stack!.count == 0 {
                            stack?.append(nextTop)
                        }
                    }
                    return
            }
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.addText(appendingText: string)
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        self.addText(appendingText: String(data: CDATABlock, encoding: .utf8) ?? "")
    }
    
    public func parser(_ parser: XMLParser, foundComment comment: String) {
        if preserveComments {
            if let top = stack?.last {
                if var comments = top[XMLDictionaryKeys.xmlDictionaryCommentsKey.rawValue] as? [String] {
                    comments.append(comment)
                    top[XMLDictionaryKeys.xmlDictionaryCommentsKey.rawValue] = comments
                }
                else {
                    top[XMLDictionaryKeys.xmlDictionaryCommentsKey.rawValue] = [comment]
                }
            }
        }
    }
    
    func nameForNode(node:XMLTupleHolder, inParentNode parentNode:XMLTupleHolder) -> String? {
        if let result = node.dict.nodeName() {
            return result
        }
        for (name, value) in parentNode.dict {
            if let object = value as? XMLTupleHolder {
                if object == node {
                    return name
                }
            }
            else if let array = value as? XMLArrayHolder {
                for entry in array.array {
                    if let tuple = entry as? XMLTupleHolder, tuple == node {
                        return name
                    }
                }
            }
        }
        return nil
    }
    
    static func XMLStringForNode(node:Any, withNodeName nodeName:String) -> String {
        var observable = node
        if let xaH = node as? XMLArrayHolder {
            observable = xaH.array
        }
        else if let xtH = node as? XMLTupleHolder {
            observable = xtH.dict
        }
        if let array = observable as? [Any] {
            var nodes:[String] = []
            for individualNode in array {
                nodes.append(XMLDictionaryParser.XMLStringForNode(node: individualNode, withNodeName: nodeName))
            }
            return nodes.joined(separator: "\n")
        }
        else if let dict = observable as? [String : Any] {
            let attributes = dict.attributes()
            var attributeString = ""
            attributes?.forEach({ (key, value) in
                attributeString = attributeString + " \(key.xmlEncodedString())=\"\(value.xmlEncodedString())\""
            })
            let innerXML = dict.innerXML()
            if innerXML.count > 0 {
                return "<\(nodeName)\(attributeString)>\(innerXML)</\(nodeName)>"
            }
            else {
                return "<\(nodeName)\(attributeString)/>"
            }
        }
        else {
            let desc = String(describing: observable)
            return "<\(nodeName)>\(desc.xmlEncodedString())</\(nodeName)>"
        }
    }
    
}
