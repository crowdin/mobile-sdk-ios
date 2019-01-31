//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

@objc public class CrowdinSDK: NSObject {
	@objc public enum Mode: Int {
		case autoSDK
		case customSDK
		case autoBundle
		case customBundle
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
			Localization.current.currentLocalization = currentLocalization
		}
	}
	
    public class var inSDKLocalizations: [String] { return Localization.current.inProvider }
    public class var inBundleLocalizations: [String] { return Localization.current.inBundle }
	
    public class func refreshUI() {
        UIUtil.shared.refresh()
    }
    
    public class func start() {
        self.initializeLib()
    }
    
    public class func deintegrate() {
        Localization.current.provider.deintegrate()
    }
    
    public class func setLocale(_ locale: String) {
        Localization.current.currentLocalization = locale
    }
    
    private class func initializeLib() {
		if self.mode == .autoSDK || self.mode == .customSDK {
			CrowdinSDK.swizzle()
		} else {
			CrowdinSDK.unswizzle()
		}
    }
	
	public class func setProvider(_ provider: LocalizationProvider) {
		Localization.current.provider = provider
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
