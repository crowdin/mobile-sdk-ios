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
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
                                                          stringsFileNames: ["Localizable.strings"],
                                                          pluralsFileNames: ["Localizable.stringsdict"],
                                                          localizations: ["en", "de", "uk"],
                                                          sourceLanguage: "en")
        let loginConfig = CrowdinLoginConfig(clientId: "XjNxVvoJh6XMf8NGnwuG",
                                             clientSecret: "Dw5TxCKvKQQRcPyAWEkTCZlxRGmcja6AFZNSld6U",
                                             scope: "project.content.screenshots",
											 redirectURI: "crowdintest://",
											 organizationName: "serhiy")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(screenshotsEnabled: true)
														.with(loginConfig: loginConfig)
                                                        .with(settingsEnabled: true)
                                                        .with(reatimeUpdatesEnabled: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig)
		
//		// Setup CrowdinSDK with crowdin sdk with all features:
//		let crowdinProviderConfig = CrowdinProviderConfig(hashString: "2db137daf26d22bf499c998106i",
//														  stringsFileNames: ["Localizable.strings"],
//														  pluralsFileNames: ["Localizable.stringsdict"],
//														  localizations: ["en", "de", "uk"],
//														  sourceLanguage: "en")
//		let loginConfig = CrowdinLoginConfig(clientId: "test-sdk",
//											 clientSecret: "79MG6E8DZfEeomalfnoKx7dA0CVuwtPC3jQTB3ts",
//											 scope: "project.content.screenshots",
//											 redirectURI: "crowdintest://")
//		let crowdinScreenshotsConfig = CrowdinScreenshotsConfig(login: "serhii.londar",
//																accountKey: "1267e86b748b600eb851f1c45f8c44ce",
//																loginConfig: loginConfig)
//		let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
//			.with(crowdinScreenshotsConfig: crowdinScreenshotsConfig)
//			.with(loginConfig: loginConfig)
//			.with(settingsEnabled: true)
//			.with(reatimeUpdatesEnabled: true)
//		CrowdinSDK.startWithConfig(crowdinSDKConfig)
		
        
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
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		print("URL - \(url)")
		print("options - \(options)")
		return CrowdinSDK.handle(url: url)
	}
}

