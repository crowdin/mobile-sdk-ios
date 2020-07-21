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
        
        // Setup CrowdinSDK with crowdin sdk with all features:
//        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "fe5e8af03e067aac4d4ec28106i",
//                                                          sourceLanguage: "en")
//        let loginConfig = try! CrowdinLoginConfig(clientId: "test-sdk",
//                                                  clientSecret: "79MG6E8DZfEeomalfnoKx7dA0CVuwtPC3jQTB3ts",
//                                                  scope: "project")
//        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
//                                                        .with(loginConfig: loginConfig)
//                                                        .with(settingsEnabled: true)
//                                                        .with(realtimeUpdatesEnabled: true)
//                                                        .with(screenshotsEnabled: true)
//        CrowdinSDK.startWithConfig(crowdinSDKConfig)    
        
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

