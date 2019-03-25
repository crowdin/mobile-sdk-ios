//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import UIKit

@objc public class CrowdinSDK: NSObject {
	@objc public enum Mode: Int {
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
	
	@objc public class var mode: Mode {
		get {
			return Localization.current.mode
		}
		set {
			Localization.current.mode = newValue
		}
	}
	
	@objc public class var currentLocalization: String? {
		get {
			return Localization.current.currentLocalization
		}
		set {
			Localization.current.currentLocalization = newValue
		}
	}
	
	// TODO: Avoid using optionals here:
	public class var inSDKLocalizations: [String] { return Localization.current?.inProvider ?? [] }
	// TODO: Avoid using optionals here:
    public class var inBundleLocalizations: [String] { return Localization.current?.inBundle ?? Bundle.main.localizations }
	
    public class func reloadUI() {
        DispatchQueue.main.async { RealtimeUpdateFeature.shared?.refresh() }
    }
    
    /// Initialization method. Initialize CrowdinProvider with passed parameters.
    ///
    /// - Parameters:
    ///   - hashString: Distribution hash value.
    ///   - stringsFileNames: Array of names of strings files.
    ///   - pluralsFileNames: Array of names of plurals files.
    @objc public class func start(with hashString: String, stringsFileNames: [String], pluralsFileNames: [String]) {
        let crowdinProvider = CrowdinProvider(hashString: hashString, stringsFileNames: stringsFileNames, pluralsFileNames: pluralsFileNames)
        self.setProvider(crowdinProvider)
        self.initializeLib()
    }
    
    /// Initialization method. Uses default CrowdinProvider with initialization values from Info.plist file.
    @objc public class func start() {
        let crowdinProvider = CrowdinProvider()
        self.setProvider(crowdinProvider)
        self.initializeLib()
    }
	
    /// Initialization method. Initialize library with passed localization provider.
    ///
    /// - Parameter provider: Custom localization provider which will be used to exchange localizations.
    @objc public class func start(with provider: LocalizationProvider) {
        self.setProvider(provider)
        self.initializeLib()
    }
    
    public class func deintegrate() {
        Localization.current.provider.deintegrate()
    }
    
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
    
    private class func initializeLib() {
		if self.mode == .customSDK || self.mode == .autoSDK {
			CrowdinSDK.swizzle()
		} else {
			CrowdinSDK.unswizzle()
		}
        ScreenshotFeature.shared = ScreenshotFeature()
    }
	
    public class func setProvider(_ provider: LocalizationProvider) {
		let localizationProvider = provider
        Localization.current = Localization(provider: localizationProvider)
    }
    
    public class func extractAllLocalization() {
        let folder = try! CrowdinFolder.shared.createFolder(with: "Extracted")
        LocalizationExtractor.extractAllLocalizationStrings(to: folder.path)
        LocalizationExtractor.extractAllLocalizationPlurals(to: folder.path)
    }
}

extension CrowdinSDK {
    class func swizzle() {
        Bundle.swizzle()
        UILabel.swizzle()
        UIButton.swizzle()
    }
    
    class func unswizzle() {
        Bundle.unswizzle()
        UILabel.unswizzle()
        UIButton.unswizzle()
    }
}
