//
//  DataParser.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/8/19.
//

import Foundation

protocol DataParser {
    associatedtype `Type`
    
    static func parse(data: Data) -> Type?
}

class CrowdinContentDelivery: DataParser {
    typealias `Type` = [AnyHashable: Any]
    
    static func parse(data: Data) -> [AnyHashable: Any]? {
        var propertyListForamat = PropertyListSerialization.PropertyListFormat.xml
        guard let dictionary = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamat) as? [AnyHashable: Any] else {
            return nil
        }
        return dictionary
    }
}
