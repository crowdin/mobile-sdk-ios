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
//        CrowdinSDK.startWithProvider(FirebaseLocalizationProvider(path: "extracted_example"))
        
        // Local
//        CrowdinSDK.start(with: LocalLocalizationProvider())
        
        // Setup CrowdinSDK with crowdin localization provider.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "66f02b964afeb77aea8d191e68748abc", stringsFileNames: ["Localizable.strings"], pluralsFileNames: ["Localizable.stringsdict"], localizations: ["en", "de"])
        CrowdinSDK.startWithConfig(CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig).with(intervalUpdatesEnabled: true, interval: 60).with(reatimeUpdatesEnabled: true).with(screnshotsEnabled: true).with(settingsEnabled: true))
        
        // Info.plist setup
//        CrowdinSDK.start()
        
        // Localization extraction
        CrowdinSDK.extractAllLocalization()
        
        let download = CrowdinSDK.addDownloadHandler {
//            CrowdinSDK.removeAllDownloadHandlers()
        }
        
        let error = CrowdinSDK.addErrorUpdateHandler { (errors) in
//            CrowdinSDK.removeAllErrorHandlers()
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

