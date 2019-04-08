//
//  DataParser.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/7/19.
//

import Foundation

protocol DataParser {
    associatedtype `Type`
    func parse(_ data: Data) -> Type?
}

class ContendDeliveryDataParser: DataParser {
    typealias `Type` = [AnyHashable: Any]
    
    func parse(_ data: Data) -> [AnyHashable : Any]? {
        var propertyListForamat = PropertyListSerialization.PropertyListFormat.xml
        guard let dictionary = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamat) as? [AnyHashable: Any] else {
            return nil
        }
        return dictionary
    }
}
