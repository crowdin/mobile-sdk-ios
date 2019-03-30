//
//  UILabel.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/23/19.
//

import Foundation
import UIKit

extension Bundle {
    // swiftlint:disable implicitly_unwrapped_optional
    static var original: Method!
    static var swizzled: Method!
    
    @objc func swizzled_LocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        var translation = Localization.current.localizedString(for: key)
        if translation == nil || translation == key {
            translation = swizzled_LocalizedString(forKey: key, value: value, table: tableName)
        }
        return translation ?? key
    }

    public class func swizzle() {
        // swiftlint:disable force_unwrapping
        original = class_getInstanceMethod(self, #selector(Bundle.localizedString(forKey:value:table:)))!
        swizzled = class_getInstanceMethod(self, #selector(Bundle.swizzled_LocalizedString(forKey:value:table:)))!
        method_exchangeImplementations(original, swizzled)
    }
    
    public class func unswizzle() {
        guard original != nil && swizzled != nil else { return }
        method_exchangeImplementations(swizzled, original)
    }
}
