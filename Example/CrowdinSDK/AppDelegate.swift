//
//  AppDelegate.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 01/22/2019.
//  Copyright (c) 2019 Serhii Londar. All rights reserved.
//

import UIKit
import CrowdinSDK
import Firebase
import FAPanels

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        FirebaseApp.configure()

        // Setup only crowdin provider:
//        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "1c2f58c7c711435295d2408106i", stringsFileNames: ["/%osx_locale%/Localizable.strings"], pluralsFileNames: ["Localizable.stringsdict"], localizations: ["en", "de"], sourceLanguage: "en")
//        CrowdinSDK.startWithConfig(CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig))

        
        
        // Setup CrowdinSDK with crowdin sdk with all features:
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "1c2f58c7c711435295d2408106i", stringsFileNames: ["/%osx_locale%/Localizable.strings"], pluralsFileNames: ["Localizable.stringsdict"], localizations: ["en", "de"], sourceLanguage: "en")
        let credentials = "YXBpLXRlc3RlcjpWbXBGcVR5WFBxM2ViQXlOa3NVeEh3aEM="
        let crowdinScreenshotsConfig = CrowdinScreenshotsConfig(login: "serhii.londar", accountKey: "1267e86b748b600eb851f1c45f8c44ce", credentials: credentials)
        CrowdinSDK.startWithConfig(CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig).with(crowdinScreenshotsConfig: crowdinScreenshotsConfig).with(settingsEnabled: true).with(reatimeUpdatesEnabled: true).with(intervalUpdatesEnabled: true, interval: 5 * 60))
        
        CrowdinSDK.captureScreenshot(name: "My awesome screenshot", success: {
            
        }) { (error) in
            
        }
        
        // Info.plist setup
//        CrowdinSDK.start()
        
        
        _ = CrowdinSDK.addDownloadHandler {
            print("Localization downloaded")
        }
        
        _ = CrowdinSDK.addErrorUpdateHandler { (errors) in
            print("Localization download failed with errors:")
            errors.forEach({ print($0.localizedDescription) })
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var panelsVC = FAPanelController()
        
        let mainVC = UIStoryboard(name: "MainViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let mainNC = UINavigationController(rootViewController: mainVC)
        
        
        let menuVC = UIStoryboard(name: "MenuVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        
        panelsVC = panelsVC.center(mainNC).left(menuVC)
        
        self.window?.rootViewController = panelsVC
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

