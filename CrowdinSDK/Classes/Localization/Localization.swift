//
//  Localization.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//

import Foundation

class Localization {
	var provider: LocalizationProvider
	
    let preferredLanguageIdentifiers = Locale.preferredLanguageIdentifiers
    
	static var current = Localization()
	
	var mode: CrowdinSDK.Mode {
		get {
			let value = UserDefaults.standard.integer(forKey: "CrowdinSDK.Localization.mode")
			return CrowdinSDK.Mode(rawValue: value) ?? CrowdinSDK.Mode.autoSDK
		}
		set {
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
				self.current = newValue
			case .autoBundle: break;
			case .customBundle:
				UserDefaults.standard.appleLanguage = newValue
			}
		}
		get {
			switch mode {
			case .autoSDK:
				return Locale.preferredLanguageIdentifiers.first(where: { provider.localizations.contains($0) })
			case .autoBundle:
				return Locale.preferredLanguageIdentifiers.first(where: { Bundle.main.localizations.contains($0) })
			case .customSDK:
				return self.current
			case .customBundle:
				return UserDefaults.standard.appleLanguage
			}
		}
	}
	
    private var current : String? {
        set {
            guard current != newValue else { return }
            UserDefaults.standard.set(newValue, forKey: "CrowdinSDK.Localization.currentLocalization")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "CrowdinSDK.Localization.currentLocalization")
        }
    }
	
	init(provider: LocalizationProvider? = nil) {
		self.provider = provider ?? CrowdinProvider(localization: "en")
		self.provider.localization = self.currentLocalization ?? "en"
	}
	
	var localization: [String : String] {
		return self.provider.localizationDict
	}

	/// A list of all avalaible localization in SDK downloaded from current provider.
	var inProvider: [String] {
		return provider.localizations
	}
    
    /// A list of all the localizations contained in the bundle.
    var inBundle: [String] {
        return Bundle.main.localizations
    }
}
