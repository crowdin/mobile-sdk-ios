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
    
    private static let localizationValuesAssociation = ObjectAssociation<[UInt: [Any]]>()
    
    var localizationValues: [UInt: [Any]]? {
        get { return UIButton.localizationValuesAssociation[self] }
        set { UIButton.localizationValuesAssociation[self] = newValue }
    }
    
    func localizationValues(for state: UIControl.State) -> [Any]? {
        return localizationValues?[state.rawValue]
    }
    // swiftlint:disable implicitly_unwrapped_optional
    static var originalSetTitle: Method!
    static var swizzledSetTitle: Method!
    static var originalSetAttributedTitle: Method!
    static var swizzledSetAttributedTitle: Method!
    
    @objc func swizzled_setTitle(_ title: String?, for state: UIControl.State) {
        proceed(title: title, for: state)
        swizzled_setTitle(title, for: state)
    }
    
    @objc func swizzled_setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        // TODO: Add saving attributes.
        let titleString = title?.string
        proceed(title: titleString, for: state)
        swizzled_setAttributedTitle(title, for: state)
    }
    
    func proceed(title: String?, for state: UIControl.State) {
        if let title = title {
            if let key = Localization.current.keyForString(title) {
                // Try to find values for key (formated strings, plurals)
                if let string = Localization.current.localizedString(for: key), string.isFormated {
                    if let values = Localization.current.findValues(for: title, with: string) {
                        // Store values in localizationValues
                        if var localizationValues = self.localizationValues {
                            localizationValues.merge(with: [state.rawValue: values])
                            self.localizationValues = localizationValues
                        } else {
                            self.localizationValues = [state.rawValue: values]
                        }
                    }
                }
                // Store key in localizationKeys
                if var localizationKeys = self.localizationKeys {
                    localizationKeys.merge(with: [state.rawValue: key])
                    self.localizationKeys = localizationKeys
                } else {
                    self.localizationKeys = [state.rawValue: key]
                }
            }
            // Subscribe to realtime updates if needed.
            if self.localizationKeys != nil {
                RealtimeUpdateFeature.shared?.subscribe(control: self)
            }
        } else {
            self.localizationKeys?[state.rawValue] = nil
            self.localizationValues?[state.rawValue] = nil
            RealtimeUpdateFeature.shared?.unsubscribe(control: self)
        }
    }
    
    func original_setTitle(_ title: String?, for state: UIControl.State) {
        guard UIButton.swizzledSetTitle != nil else { return }
        swizzled_setTitle(title, for: state)
    }
    
    func original_setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        // TODO: Add saving attributes.
        guard UIButton.swizzledSetAttributedTitle != nil else { return }
        swizzled_setAttributedTitle(title, for: state)
    }

    public class func swizzle() {
        // swiftlint:disable force_unwrapping
        originalSetTitle = class_getInstanceMethod(self, #selector(UIButton.setTitle(_:for:)))!
        swizzledSetTitle = class_getInstanceMethod(self, #selector(UIButton.swizzled_setTitle(_:for:)))!
        method_exchangeImplementations(originalSetTitle, swizzledSetTitle)
        
        originalSetAttributedTitle = class_getInstanceMethod(self, #selector(UIButton.setAttributedTitle(_:for:)))!
        swizzledSetAttributedTitle = class_getInstanceMethod(self, #selector(UIButton.swizzled_setAttributedTitle(_:for:)))!
        method_exchangeImplementations(originalSetTitle, swizzledSetTitle)
    }
    
    public class func unswizzle() {
        guard originalSetTitle != nil && swizzledSetTitle != nil else { return }
        method_exchangeImplementations(swizzledSetTitle, originalSetTitle)
    }
}
