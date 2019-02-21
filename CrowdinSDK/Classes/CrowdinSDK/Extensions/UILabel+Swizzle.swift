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
    
    static var original: Method!
    static var swizzled: Method!

    @objc func swizzled_setText(_ text: String) {
        self.localizationKey = Localization.current.keyForString(text)
		
		let isFormated = text.isFormated
		if !isFormated, let key = localizationKey, let string = Localization.current.localizedString(for: key), string.isFormated {
			self.localizationValues = Localization.current.findValues(for: text, with: string)
		}
		if isFormated, let values = self.localizationValues {
            let newText = String(format: text, arguments: values as! [CVarArg])
			swizzled_setText(newText)
			return
		} else {
        	swizzled_setText(text)
		}
    }


    public class func swizzle() {
        original = class_getInstanceMethod(self, #selector(setter: UILabel.text))!
        swizzled = class_getInstanceMethod(self, #selector(UILabel.swizzled_setText(_:)))!
        method_exchangeImplementations(original, swizzled)
    }
    
    public class func unswizzle() {
        guard original != nil && swizzled != nil else { return }
        method_exchangeImplementations(swizzled, original)
    }
}

