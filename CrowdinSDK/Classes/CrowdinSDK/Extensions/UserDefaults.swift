//
//  UserDefaults.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

extension UserDefaults {
	enum Keys: String {
		case AppleLanguages
	}
	
	var appleLanguages: [String]? {
		get {
			return UserDefaults.standard.array(forKey: Keys.AppleLanguages.rawValue) as? [String]
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.AppleLanguages.rawValue)
			UserDefaults.standard.synchronize()
		}
	}
	
	var appleLanguage: String? {
		get {
			return self.appleLanguages?.first
		}
		set {
            if let value = newValue {
                self.appleLanguages = [value]
            } else {
                self.appleLanguages = nil
            }
		}
	}
	
	func cleanAppleLanguages() {
		self.appleLanguage = nil
	}
}
