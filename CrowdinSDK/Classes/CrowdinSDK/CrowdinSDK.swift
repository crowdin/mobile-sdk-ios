//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import UIKit
import Foundation

/// Closure type for localization update download handlers.
public typealias CrowdinSDKLocalizationUpdateDownload = () -> Void

/// Closure type for localization update error handlers.
public typealias CrowdinSDKLocalizationUpdateError = ([Error]) -> Void

/// Main interface for working with CrowdinSDK library.
@objcMembers public class CrowdinSDK: NSObject {
    /// Enum representing available SDK modes.
    ///
    /// autoSDK - Automaticly detect current localization and change localized strings to crowdin strings.
    ///
    /// customSDK - Enable user defined localization from crowdin supported languages.
    ///
    /// autoBundle - Does not enable crowdin localization. In this mode will be used bundle localization detected by system.
    ///
    /// customBundle - Set user defined localization from bundle supported languages.
	public enum Mode: Int {
		case autoSDK
		case customSDK
		case autoBundle
		case customBundle
        
        var isAutoMode: Bool {
            return self == .autoSDK || self == .autoBundle
        }
        
        var isSDKMode: Bool {
            return self == .autoSDK || self == .customSDK
        }
	}
	
    /// Current SDK mode.
	public class var mode: Mode {
		get {
			return Localization.current.mode
		}
		set {
			Localization.current.mode = newValue
		}
	}
	
    /// Current localization language code.
	public class var currentLocalization: String? {
		get {
			return Localization.current.currentLocalization
		}
		set {
			Localization.current.currentLocalization = newValue
		}
	}
	
    /// List of avalaible localizations in SDK.
	public class var inSDKLocalizations: [String] { return Localization.current?.inProvider ?? [] }
	
    /// List of supported in app localizations.
    public class var inBundleLocalizations: [String] { return Localization.current?.inBundle ?? Bundle.main.localizations }
    
    // swiftlint:disable implicitly_unwrapped_optional
    static var config: CrowdinSDKConfig!
    
    ///
    public class func stop() {
        self.unswizzle()
        Localization.current = nil
    }
	
    /// Initialization method. Initialize library with passed localization provider.
    ///
    /// - Parameter provider: Custom localization provider which will be used to exchange localizations.
    class func startWithRemoteStorage(_ remoteStorage: RemoteLocalizationStorageProtocol, localizations: [String]) {
        self.setRemoteStorage(remoteStorage, localizations: localizations)
        self.initializeLib()
    }
    
    /// Removes all stored information by SDK from application Documents folder. Use to clean up all files used by SDK.
    public class func deintegrate() {
        Localization.current.provider.deintegrate()
    }
    
    /// Method for changing SDK lcoalization and mode. There are 4 avalaible modes in SDK. For more information please look on Mode enum description.
    ///
    /// - Parameters:
    ///   - sdkLocalization: Bool value which indicate whether to use SDK localization or native in bundle localization.
    ///   - localization: Localization code to use.
    public class func enableSDKLocalization(_ sdkLocalization: Bool, localization: String?) {
        if sdkLocalization {
            if localization != nil {
                self.mode = .customSDK
            } else {
                self.mode = .autoSDK
            }
        } else {
            if localization != nil {
                self.mode = .customBundle
            } else {
                self.mode = .autoBundle
            }
        }
        self.currentLocalization = localization
    }
	
    /// Sets localization provider to SDK. If you want to use your own localization implementation you can set it by using this method. Note: your object should be inherited from @BaseLocalizationProvider class.
    ///
    /// - Parameter provider: Localization provider which contains all strings, plurals and avalaible localizations values.
    class func setRemoteStorage(_ remoteStorage: RemoteLocalizationStorageProtocol, localizations: [String]) {
        let localization = Bundle.main.preferredLanguage
		let localizationProvider = LocalizationProvider(localization: localization, localizations: localizations, remoteStorage: remoteStorage)
        Localization.current = Localization(provider: localizationProvider)
    }
    
    /// Utils method for extracting all localization strings and plurals to Documents folder. This method will extract all localization for all languages and store it in Extracted subfolder in Crowdin folder.
    public class func extractAllLocalization() {
        guard let folder = try? CrowdinFolder.shared.createFolder(with: "Extracted") else { return }
        LocalizationExtractor.extractAllLocalizationStrings(to: folder.path)
        LocalizationExtractor.extractAllLocalizationPlurals(to: folder.path)
    }
    
    /// Add download handler closure. This closure will be called every time when new localization is downloaded.
    ///
    /// - Parameter handler: Download handler closure.
    /// - Returns: Download handler id value. This value is used to remove this handler.
    public class func addDownloadHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateDownload) -> Int {
        return Localization.current?.addDownloadHandler(handler) ?? -1
    }
    
    /// Remove download handler by id.
    ///
    /// - Parameter id: Download handler id value.
    public class func removeDownloadHandler(_ id: Int) {
        Localization.current?.removeDownloadHandler(id)
    }
    
    /// Remove all download handlers.
    public class func removeAllDownloadHandlers() {
        Localization.current?.removeAllDownloadHandlers()
    }
    
    /// Add error handler
    ///
    /// - Parameter handler: Error handler closure.
    /// - Returns: Error handler id value. This value is used to remove this handler.
    public class func addErrorUpdateHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateError) -> Int {
        return Localization.current?.addErrorUpdateHandler(handler) ?? -1
    }
    
    /// Remove error handler by id.
    ///
    /// - Parameter id: Error's handler id value.
    public class func removeErrorHandler(_ id: Int) {
        Localization.current?.removeErrorHandler(id)
    }
    
    /// Remove all error handlers.
    public class func removeAllErrorHandlers() {
        Localization.current.removeAllErrorHandlers()
    }
}

extension CrowdinSDK {
    /// Method for swizzling all needed methods.
    class func swizzle() {
        if !Bundle.isSwizzled {
            Bundle.swizzle()
        }
        if !UILabel.isSwizzled {
            UILabel.swizzle()
        }
        if !UIButton.isSwizzled {
            UIButton.swizzle()
        }
    }
    
    /// Method for unswizzling all zwizzled methods.
    class func unswizzle() {
        Bundle.unswizzle()
        UILabel.unswizzle()
        UIButton.unswizzle()
    }
}

extension CrowdinSDK {
    /// Selectors for all feature initialization.
    ///
    /// - initializeScreenshotFeature: Selector for Screenshots feature initialization.
	/// - initializeRealtimeUpdatesFeature: Selector for RealtimeUpdates feature initialization.
	/// - initializeIntervalUpdateFeature: Selector for IntervalUpdate feature initialization.
	/// - initializeSettings: Selector for Settings feature initialization.
    enum Selectors: Selector {
        case initializeScreenshotFeature
        case initializeRealtimeUpdatesFeature
        case initializeIntervalUpdateFeature
        case initializeSettings
		case setupLogin
    }
    
    /// Method for library initialization.
    class func initializeLib() {
        if self.mode == .customSDK || self.mode == .autoSDK {
            CrowdinSDK.swizzle()
        } else {
            CrowdinSDK.unswizzle()
        }
        
        self.setupLoginIfNeeded()
        
        self.initializeScreenshotFeatureIfNeeded()
        
        self.initializeRealtimeUpdatesFeatureIfNeeded()
        
        self.initializeIntervalUpdateFeatureIfNeeded()
        
        self.initializeSettingsIfNeeded()
    }
    
    /// Method for screenshot feature initialization if Screenshot submodule is added.
    private class func initializeScreenshotFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeScreenshotFeature.rawValue) {
            CrowdinSDK .perform(Selectors.initializeScreenshotFeature.rawValue)
        }
    }
	
    /// Method for real-time updates feature initialization if RealtimeUpdate submodule is added.
    private class func initializeRealtimeUpdatesFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeRealtimeUpdatesFeature.rawValue) {
            CrowdinSDK .perform(Selectors.initializeRealtimeUpdatesFeature.rawValue)
        }
    }
	
	/// Method for interval updates feature initialization if IntervalUpdate submodule is added.
    private class func initializeIntervalUpdateFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeIntervalUpdateFeature.rawValue) {
            CrowdinSDK .perform(Selectors.initializeIntervalUpdateFeature.rawValue)
        }
    }
	
	/// Method for Settings view feature initialization if Screenshots submodule is added.
    private class func initializeSettingsIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeSettings.rawValue) {
            CrowdinSDK .perform(Selectors.initializeSettings.rawValue)
        }
    }
	
	private class func setupLoginIfNeeded() {
		if CrowdinSDK.responds(to: Selectors.setupLogin.rawValue) {
			CrowdinSDK .perform(Selectors.setupLogin.rawValue)
		}
	}
}
