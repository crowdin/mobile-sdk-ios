//
//  UILabel.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/23/19.
//

import Foundation
import UIKit

extension Bundle {
    static var original: Method!
    static var swizzled: Method!
    
    @objc func swizzled_LocalizedString(forKey key: String?, value: String?, table tableName: String?) -> String? {
        var translation: String? = nil
        if translation == nil {
            translation = swizzled_LocalizedString(forKey: key, value: value, table: tableName) ?? ""
        }
        return translation ?? "translation";
    }

    public class func swizzle() {
        original = class_getInstanceMethod(self, #selector(Bundle.localizedString(forKey:value:table:)))!
        swizzled = class_getInstanceMethod(self, #selector(Bundle.swizzled_LocalizedString(forKey:value:table:)))!
        method_exchangeImplementations(original, swizzled)
    }
}
