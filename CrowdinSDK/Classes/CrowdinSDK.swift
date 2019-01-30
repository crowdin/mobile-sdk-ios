//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

public class CrowdinSDK: NSObject {
    public class var inSDKLocalizations: [String] { return Localization.shared.inSDK }
    public class var inBundleLocalizations: [String] { return Localization.shared.inBundle }
    public class var currentLocalization: String { return Localization.shared.current }
    
    public class var enabled: Bool {
        set {
            guard newValue != enabled else { return }
            UserDefaults.standard.set(newValue, forKey: "CrowdinSDK.enabled")
            UserDefaults.standard.synchronize()
            if newValue {
                CrowdinSDK.swizzle()
            } else {
                CrowdinSDK.unswizzle()
            }
        }
        get {
            return UserDefaults.standard.bool(forKey: "CrowdinSDK.enabled")
        }
    }
    
    public class func refresh() {
        Localization.shared.refresh()
        UIUtil.shared.refresh()
    }
    
    public class func start() {
        self.initializeLib()
    }
    
    public class func deintegrate() {
        self.deleteCrowdinFolder()
    }
    
    public class func setLocale(_ locale: String?) {
        Localization.shared.set(localization: locale)
    }
    
    private class func initializeLib() {
        if CrowdinSDK.enabled {
            CrowdinSDK.swizzle()
        }
        self.createCrowdinFolderIfNeeded()
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


extension CrowdinSDK {
    class func createCrowdinFolderIfNeeded() {
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
        if !crowdinFolder.isCreated { try? crowdinFolder.create() }
    }
    
    class func deleteCrowdinFolder() {
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
        if crowdinFolder.isCreated { try? crowdinFolder.delete() }
    }
}
