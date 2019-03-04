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
        DispatchQueue.main.async { UIUtil.shared.refresh() }
    }
    
    @objc public class func start() {
        self.setProvider(nil)
        self.initializeLib()
    }
	
    @objc public class func start(with provider: LocalizationProvider?) {
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
    }
	
    public class func setProvider(_ provider: LocalizationProvider?) {
		let localizationProvider = provider ?? CrowdinProvider()
        Localization.current = Localization(provider: localizationProvider)
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
