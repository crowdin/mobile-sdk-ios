//
//  Bundle+Language.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/5/19.
//

import Foundation

extension Bundle {
    var preferredLanguage: String {
        return self.preferredLanguages.first ?? defaultLocalization
    }
    /// Return ordered list of language codes according to device settings, and bundle localizations.
	//	TODO: Add handling case when intersection of preffered languages from settings and localizations in bundle is empty.
    var preferredLanguages: [String] {
        var preferredLanguages = Locale.preferredLocalizations
		let localizations = self.localizations.compactMap { (localization) -> String? in
			if preferredLanguages.contains(localization) {
				return localization
			}
			return nil
		}
		preferredLanguages = preferredLanguages.compactMap { (localization) -> String? in
			if localizations.contains(localization) {
				return localization
			}
			return nil
		}
        return preferredLanguages
    }
}
