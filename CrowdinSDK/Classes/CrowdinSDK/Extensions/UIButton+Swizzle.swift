//
//  UIButton+Swizzle.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/27/19.
//

import UIKit

extension UIControl.State: Hashable {
    static let all: [UIControl.State] = [.normal, .selected, .disabled, .highlighted]
    public var hashValue: Int { return Int(rawValue) }
}

extension UIButton {
    private static let localizationKeyAssociation = ObjectAssociation<[UInt: String]>()
    
    var localizationKeys: [UInt: String]? {
        get { return UIButton.localizationKeyAssociation[self] }
        set { UIButton.localizationKeyAssociation[self] = newValue }
    }
    
    func localizationKey(for state: UIControl.State) -> String? {
        return localizationKeys?[state.rawValue]
    }
    
    static var original: Method!
    static var swizzled: Method!
    @objc func swizzled_setTitle(_ title: String?, for state: UIControl.State) {
        let key = Localization.current.keyForString(title ?? "")
        if let key = key {
            if var localizationKeys = self.localizationKeys {
                localizationKeys.merge(dict: [state.rawValue: key])
                self.localizationKeys = localizationKeys
            } else {
                self.localizationKeys = [state.rawValue: key]
            }
        }
        swizzled_setTitle(title, for: state)
    }
    
    public class func swizzle() {
        original = class_getInstanceMethod(self, #selector(UIButton.setTitle(_:for:)))!
        swizzled = class_getInstanceMethod(self, #selector(UIButton.swizzled_setTitle(_:for:)))!
        method_exchangeImplementations(original, swizzled)
    }
    
    public class func unswizzle() {
        guard original != nil && swizzled != nil else { return }
        method_exchangeImplementations(swizzled, original)
    }
}
