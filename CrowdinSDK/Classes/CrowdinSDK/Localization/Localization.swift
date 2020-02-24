//
//  Localization.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//

import Foundation

/// Helper class for working with localization providers and extractors. Store all needed information such as: mode, current localization value, ect.
class Localization {
    /// Current localization provider.
	var provider: LocalizationProviderProtocol
    
    /// Localization extractor.
    var extractor: LocalizationExtractor
    
    /// Ordered array of preffered localization language codes according to device settings, and bundle localizations.
    fileprivate let preferredLocalizations = Bundle.main.preferredLanguages
    
    // swiftlint:disable implicitly_unwrapped_optional
    /// Instance of shared @Localization class instance.
    static var current: Localization! = nil
	
    /// Property for detecting and storing current SDK mode value.
	var mode: CrowdinSDK.Mode {
		get {
			let value = UserDefaults.standard.mode
			return CrowdinSDK.Mode(rawValue: value) ?? CrowdinSDK.Mode.autoSDK
		}
		set {
            UserDefaults.standard.cleanAppleLanguages()
            switch newValue {
            case .autoSDK, .customSDK,.autoBundle:
                UserDefaults.standard.cleanAppleLanguages()
            case .customBundle: break
            }
			UserDefaults.standard.mode = newValue.rawValue
		}
	}
	
    /// Property for detecting and storing curent localization value depending on current SDK mode.
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
            self.provider.localization = newValue ?? Bundle.main.preferredLanguage
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
	
    /// Property for storing specific localization value in UserDefaults. This value used for custom in SDK localization.
    private var customLocalization: String? {
        set {
            UserDefaults.standard.customLocalization = newValue
        }
        get {
            return UserDefaults.standard.customLocalization
        }
    }
	
    /// Initialize object with specific localization provider.
    ///
    /// - Parameter provider: Localization provider implementation.
	init(provider: LocalizationProviderProtocol) {
        self.extractor = LocalizationExtractor()
        self.provider = provider
        self.provider.localization = currentLocalization ?? Bundle.main.preferredLanguage
        self.extractor.setLocalization(currentLocalization ?? defaultLocalization)
	}
	
	/// A list of all avalaible localization in SDK downloaded from current provider.
	var inProvider: [String] {
		return provider.localizations
	}
    
    /// A list of all the localizations contained in the bundle.
    var inBundle: [String] {
        return Bundle.main.localizations
    }
    
    /// Find localization key for a given text.
    ///
    /// - Parameter text: Text to find key for.
    /// - Returns: Localization key for given text. If there are no such text in localization strings then method will return nil.
    func keyForString(_ text: String) -> String? {
        var key = provider.key(for: text)
        if key == nil {
            // TODO: Add proper method to extractor for getting keys.
            key = extractor.localizationDict.first(where: { $1 == text })?.key
        }
        return key
    }
    
    /// Find localization string for geiven key.
    ///
    /// - Parameter key: Key to find localization string for.
    /// - Returns: Localization key string value. If string woun't find method will return key value.
    func localizedString(for key: String) -> String? {
        return self.provider.localizedString(for: key)
    }
	
    /// Method for detecting formated values in string by given format.
    ///
    /// - Parameters:
    ///   - string: Given localized string.
    ///   - format: String format.
    /// - Returns: Detected values. If values aren't detected than method will return nil.
	func findValues(for string: String, with format: String) -> [Any]? {
		return provider.values(for:string, with:format)
	}
    
    // MARK: Download observer
    var localizationUpdateObserver = LocalizationUpdateObserver()
    
    /// Method for adding localization download completion handler.
    ///
    /// - Parameter handler: Download completion closure.
    /// - Returns: Handler id needed to unsubscribe.
    func addDownloadHandler(_ handler: @escaping () -> Void) -> Int {
        return localizationUpdateObserver.addDownloadHandler(handler)
    }
    
    /// Method for removing localization download completion handler by id.
    ///
    /// - Parameter id: Handler id returned from addDownloadHandler(_:) method.
    func removeDownloadHandler(_ id: Int) {
        localizationUpdateObserver.removeDownloadHandler(id)
    }
    
    /// Remove all download completion handlers.
    func removeAllDownloadHandlers() {
        localizationUpdateObserver.removeAllDownloadHandlers()
    }
    
    /// Method for adding localization download error handler.
    ///
    /// - Parameter handler: Download error closure.
    /// - Returns: Handler id needed to unsubscribe.
    func addErrorUpdateHandler(_ handler: @escaping ([Error]) -> Void) -> Int {
        return localizationUpdateObserver.addErrorHandler(handler)
    }
    
    /// Method for removing localization download error handler.
    ///
    /// - Parameter id: Handler id returned from addErrorUpdateHandler(_:) method.
    func removeErrorHandler(_ id: Int) {
        localizationUpdateObserver.removeErrorHandler(id)
    }
    
    /// Method for removing all localization download error handlers.
    func removeAllErrorHandlers() {
        localizationUpdateObserver.removeAllErrorHandlers()
    }
}
