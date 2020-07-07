//
//  AppDelegate.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 01/22/2019.
//  Copyright (c) 2019 Serhii Londar. All rights reserved.
//

import UIKit
import CrowdinSDK
import FAPanels

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup only crowdin provider:
//        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "1c2f58c7c711435295d2408106i", stringsFileNames: ["/%osx_locale%/Localizable.strings"], pluralsFileNames: ["Localizable.stringsdict"], localizations: ["en", "de"], sourceLanguage: "en")
//        CrowdinSDK.startWithConfig(CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig))

        
        
        // Setup CrowdinSDK with crowdin sdk with all features for enterprise:
//        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
//                                                          localizations: ["en", "de", "uk"],
//                                                          sourceLanguage: "en")
//        let loginConfig = try! CrowdinLoginConfig(clientId: "XjNxVvoJh6XMf8NGnwuG",
//                                                  clientSecret: "Dw5TxCKvKQQRcPyAWEkTCZlxRGmcja6AFZNSld6U",
//                                                  scope: "project.screenshot",
//                                                  redirectURI: "crowdintest://",
//                                                  organizationName: "serhiy")
//        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
//                                                        .with(screenshotsEnabled: true)
//														  .with(loginConfig: loginConfig)
//                                                        .with(settingsEnabled: true)
//                                                        .with(realtimeUpdatesEnabled: true)
//        CrowdinSDK.startWithConfig(crowdinSDKConfig)
		
		// Setup CrowdinSDK with crowdin sdk with all features:
		let crowdinProviderConfig = CrowdinProviderConfig(hashString: "fe5e8af03e067aac4d4ec28106i",
														  sourceLanguage: "en")
		let loginConfig = try! CrowdinLoginConfig(clientId: "test-sdk",
                                                  clientSecret: "79MG6E8DZfEeomalfnoKx7dA0CVuwtPC3jQTB3ts",
                                                  scope: "project")
		let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(loginConfig: loginConfig)
                                                        .with(settingsEnabled: true)
                                                        .with(realtimeUpdatesEnabled: true)
                                                        .with(screenshotsEnabled: true)
		CrowdinSDK.startWithConfig(crowdinSDKConfig)
        
        print(CrowdinSDK.localizationDictionary(for: "en"))
        
//		Setup CrowdinSDK with Info.plist. Initializes only localization delivery feature.
//        CrowdinSDK.start()
        
//        _ = CrowdinSDK.addDownloadHandler {
//            print("Localization downloaded")
//        }
//
//        _ = CrowdinSDK.addErrorUpdateHandler { (errors) in
//            print("Localization download failed with errors:")
//            errors.forEach({ print($0.localizedDescription) })
//        }
        
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
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		print("URL - \(url)")
		print("options - \(options)")
		return CrowdinSDK.handle(url: url)
	}
}

