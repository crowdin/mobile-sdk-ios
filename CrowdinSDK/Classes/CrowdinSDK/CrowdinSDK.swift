//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import UIKit
import Foundation

public typealias CrowdinSDKLocalizationUpdateDownload = () -> Void
public typealias CrowdinSDKLocalizationUpdateError = ([Error]) -> Void

/// Main interface For working with CrowdinSDK library.
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
    
    static var config: CrowdinSDKConfig!
    
    /// Initialization method. Initialize CrowdinProvider with passed parameters.
    ///
    /// - Parameters:
    ///   - hashString: Distribution hash value.
    ///   - stringsFileNames: Array of names of strings files.
    ///   - pluralsFileNames: Array of names of plurals files.
    public class func startWithConfig(_ config: CrowdinSDKConfig) {
        self.config = config
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        let localization = Bundle.main.preferredLanguage(with: crowdinProviderConfig.localizations)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        self.setRemoteStorage(remoteStorage)
        self.initializeLib()
    }
    
    /// Initialization method. Uses default CrowdinProvider with initialization values from Info.plist file.
    public class func start() {
        self.startWithConfig(CrowdinSDKConfig.config())
    }
	
    /// Initialization method. Initialize library with passed localization provider.
    ///
    /// - Parameter provider: Custom localization provider which will be used to exchange localizations.
    class func startWithRemoteStorage(_ remoteStorage: RemoteLocalizationStorageProtocol) {
        self.setRemoteStorage(remoteStorage)
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
			self.currentLocalization = localization
        } else {
            if localization != nil {
                self.mode = .customBundle
            } else {
                self.mode = .autoBundle
            }
			self.currentLocalization = localization
        }
    }
	
    /// Sets localization provider to SDK. If you want to use your own localization implementation you can set it by using this method. Note: your object should be inherited from @BaseLocalizationProvider class.
    ///
    /// - Parameter provider: Localization provider which contains all strings, plurals and avalaible localizations values.
    class func setRemoteStorage(_ remoteStorage: RemoteLocalizationStorageProtocol) {
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        let localization = Bundle.main.preferredLanguage(with: crowdinProviderConfig.localizations)
		let localizationProvider = LocalizationProvider(localization: localization, localizations: crowdinProviderConfig.localizations, remoteStorage: remoteStorage)
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
    public class func addDownloadHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateDownload) -> UInt {
        return Localization.current.addDownloadHandler(handler)
    }
    
    /// Remove download handler by id.
    ///
    /// - Parameter id: Download handler id value.
    public class func removeDownloadHandler(_ id: UInt) {
        Localization.current.removeDownloadHandler(id)
    }
    
    /// Remove all download handlers.
    public class func removeAllDownloadHandlers() {
        Localization.current.removeAllDownloadHandlers()
    }
    
    /// Add error handler
    ///
    /// - Parameter handler: Error handler closure.
    /// - Returns: Error handler id value. This value is used to remove this handler.
    public class func addErrorUpdateHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateError) -> UInt {
        return Localization.current.addErrorUpdateHandler(handler)
    }
    
    /// Remove error handler by id.
    ///
    /// - Parameter id: Error's handler id value.
    public class func removeErrorHandler(_ id: UInt) {
        Localization.current.removeErrorHandler(id)
    }
    
    /// Remove all error handlers.
    public class func removeAllErrorHandlers() {
        Localization.current.removeAllErrorHandlers()
    }
}

extension CrowdinSDK {
    /// Method for swizzling all needed methods.
    class func swizzle() {
        Bundle.swizzle()
        UILabel.swizzle()
        UIButton.swizzle()
    }
    
    /// Method for unswizzling all zwizzled methods.
    class func unswizzle() {
        Bundle.unswizzle()
        UILabel.unswizzle()
        UIButton.unswizzle()
    }
}

extension CrowdinSDK {
    /// Method for library initialization.
    private class func initializeLib() {
        if self.mode == .customSDK || self.mode == .autoSDK {
            CrowdinSDK.swizzle()
        } else {
            CrowdinSDK.unswizzle()
        }
        if CrowdinSDK.responds(to: Selector(("initializeScreenshotFeature"))) {
            CrowdinSDK .perform(Selector(("initializeScreenshotFeature")))
        }
        if CrowdinSDK.responds(to: Selector(("initializeRealtimeUpdatesFeature"))) {
            CrowdinSDK .perform(Selector(("initializeRealtimeUpdatesFeature")))
        }
        
        if CrowdinSDK.responds(to: Selector(("initializeIntervalUpdateFeature"))) {
            CrowdinSDK .perform(Selector(("initializeIntervalUpdateFeature")))
        }
        
        if CrowdinSDK.responds(to: Selector(("initializeSettings"))) {
            CrowdinSDK .perform(Selector(("initializeSettings")))
        }
    }
}
