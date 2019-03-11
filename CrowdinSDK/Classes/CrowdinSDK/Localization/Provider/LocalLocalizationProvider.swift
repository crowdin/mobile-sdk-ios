//
//  LocalLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

public class LocalLocalizationProvider: BaseLocalizationProvider {
	
	var additionalWord: String
	
	public override init() {
		self.additionalWord = "[cw]"
		super.init()
		self.localizations = Bundle.main.localizations
	}
	
    public init(additionalWord: String) {
		self.additionalWord = additionalWord
        super.init()
        self.localizations = Bundle.main.localizations
    }
    
    required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
		self.additionalWord = "[cw]"
        super.init(localizations: localizations, strings: strings, plurals: plurals)
        self.localizations = Bundle.main.localizations
    }
    
    override public func set(localization: String?) {
        super.set(localization: localization)
        refresh()
    }
    
    func refresh() {
        let extractor = LocalizationExtractor(localization: self.localization)
		let plurals = self.addAdditionalWordTo(plurals: extractor.localizationPluralsDict)
        self.set(plurals: plurals)
        let strings = self.addAdditionalWordTo(strings: extractor.localizationDict)
        self.set(strings: strings)
    }
	
	func addAdditionalWordTo(strings: [String: String]) -> [String: String] {
		var dict = strings
		dict.keys.forEach { (key) in
			dict[key] = dict[key]! + "[\(localization)][\(additionalWord)]"
		}
		return dict
	}
	
	func addAdditionalWordTo(plurals: [AnyHashable: Any]) -> [AnyHashable: Any] {
		var dict = plurals
		dict.keys.forEach({ (key) in
			var localized = dict[key] as! [AnyHashable: Any]
			localized.keys.forEach({ (key1) in
				if key1 as! String == "NSStringLocalizedFormatKey" { return }
				var value = localized[key1] as! [String: String]
				value.keys.forEach({ (key) in
					guard key != "NSStringFormatSpecTypeKey" else { return }
					guard key != "NSStringFormatValueTypeKey" else { return }
					
					value[key] = value[key]! + "[\(localization)][\(additionalWord)]"
				})
				localized[key1 as! String] = value
			})
			dict[key] = localized
		})
		return dict
	}
}
