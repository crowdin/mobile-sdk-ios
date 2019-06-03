//
//  UILabel.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/23/19.
//

import Foundation
import UIKit

extension UILabel {
    private static let localizationKeyAssociation = ObjectAssociation<String>()
    
    var localizationKey: String? {
        get { return UILabel.localizationKeyAssociation[self] }
        set { UILabel.localizationKeyAssociation[self] = newValue }
    }
	
	private static let localizationValuesAssociation = ObjectAssociation<[Any]>()
	
	var localizationValues: [Any]? {
		get { return UILabel.localizationValuesAssociation[self] }
		set { UILabel.localizationValuesAssociation[self] = newValue }
	}
    // swiftlint:disable implicitly_unwrapped_optional
    static var originalText: Method!
    static var swizzledText: Method!
    static var originalAttributedText: Method!
    static var swizzledAttributedText: Method!

    @objc func swizzled_setText(_ text: String?) {
		proceed(text: text)
        swizzled_setText(text)
    }
    
    @objc func swizzled_setAttributedText(_ attributedText: NSAttributedString?) {
        // TODO: Add saving attributes.
        proceed(text: attributedText?.string)
        swizzled_setAttributedText(attributedText)
    }
    
    func proceed(text: String?) {
        if let text = text {
            self.localizationKey = Localization.current.keyForString(text)
            
            if self.localizationKey != nil {
                RealtimeUpdateFeature.shared?.subscribe(control: self)
            }
            
            if let key = localizationKey, let string = Localization.current.localizedString(for: key), string.isFormated {
                self.localizationValues = Localization.current.findValues(for: text, with: string)
            }
        } else {
            self.localizationKey = nil
            self.localizationValues = nil
            RealtimeUpdateFeature.shared?.unsubscribe(control: self)
        }
    }
    
    func original_setText(_ text: String) {
        guard UILabel.swizzledText != nil else { return }
        swizzled_setText(text)
    }
    
    func original_setAttributedText(_ attributedText: NSAttributedString?) {
        // TODO: Add saving attributes.
        guard UILabel.swizzledAttributedText != nil else { return }
        swizzled_setAttributedText(attributedText)
    }

    class func swizzle() {
        // swiftlint:disable force_unwrapping
        originalText = class_getInstanceMethod(self, #selector(setter: UILabel.text))!
        swizzledText = class_getInstanceMethod(self, #selector(UILabel.swizzled_setText(_:)))!
        method_exchangeImplementations(originalText, swizzledText)
        
        originalAttributedText = class_getInstanceMethod(self, #selector(setter: UILabel.attributedText))!
        swizzledAttributedText = class_getInstanceMethod(self, #selector(UILabel.swizzled_setAttributedText(_:)))!
        method_exchangeImplementations(originalAttributedText, swizzledAttributedText)
    }
    
    class func unswizzle() {
        if originalText != nil && swizzledText != nil {
            method_exchangeImplementations(swizzledText, originalText)
        }
        if originalAttributedText != nil && swizzledAttributedText != nil {
            method_exchangeImplementations(originalAttributedText, swizzledAttributedText)
        }
    }
}
