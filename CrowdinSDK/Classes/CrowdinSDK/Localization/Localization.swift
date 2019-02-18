//
//  Localization.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//

import Foundation

class Localization {
	var provider: LocalizationProvider
    var extractor: LocalizationExtractor
    
    fileprivate let preferredLocalizations = Bundle.main.preferredLanguages
    
    static var current: Localization! = nil
	
	var mode: CrowdinSDK.Mode {
		get {
			let value = UserDefaults.standard.integer(forKey: "CrowdinSDK.Localization.mode")
			return CrowdinSDK.Mode(rawValue: value) ?? CrowdinSDK.Mode.autoSDK
		}
		set {
            UserDefaults.standard.cleanAppleLanguages()
            switch newValue {
            case .autoSDK, .customSDK,.autoBundle:
                UserDefaults.standard.cleanAppleLanguages()
            case .customBundle: break
            }
			// TODO: Add changes after switching mode. f.e. cleanAppleLanguages.
			UserDefaults.standard.set(newValue.rawValue, forKey: "CrowdinSDK.Localization.mode")
			UserDefaults.standard.synchronize()
		}
	}
	
	var currentLocalization: String? {
		set {
			switch mode {
			case .autoSDK: break;
			case .customSDK:
				self.customLocalization = newValue
			case .autoBundle: break;
			case .customBundle:
				UserDefaults.standard.appleLanguage = newValue
			}
            self.provider.set(localization: newValue)
		}
		get {
			switch mode {
			case .autoSDK:
				return preferredLocalizations.first(where: { provider.localizations.contains($0) })
			case .autoBundle:
				return preferredLocalizations.first(where: { self.inBundle.contains($0) })
			case .customSDK:
				return self.customLocalization
			case .customBundle:
				return UserDefaults.standard.appleLanguage
			}
		}
	}
	
    private var customLocalization : String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "CrowdinSDK.Localization.customLocalization")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "CrowdinSDK.Localization.customLocalization")
        }
    }
	
	init(provider: LocalizationProvider? = nil) {
        self.extractor = LocalizationExtractor()
        self.provider = provider ?? CrowdinProvider()
        self.provider.set(localization: currentLocalization)
        self.extractor.setLocalization(currentLocalization)
	}
	
    func localizedString(for key: String) -> String? {
		return self.provider.localizedString(for: key)
	}

	/// A list of all avalaible localization in SDK downloaded from current provider.
	var inProvider: [String] {
		return provider.localizations
	}
    
    /// A list of all the localizations contained in the bundle.
    var inBundle: [String] {
        return Bundle.main.localizations
    }
    
    func keyForString(_ text: String) -> String? {
        var key = provider.keyForString(text)
        if key == nil {
			// TODO: Add proper method to extractor for getting keys.
            key = extractor.localizationDict.first(where: { $1 == text })?.key
        }
        return key
    }
	
	func findValues(for string: String, with format: String) -> [String] {
		return provider.findValues(for:string, with:format)
	}
}
