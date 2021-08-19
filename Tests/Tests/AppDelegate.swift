//
//  AppDelegate.swift
//  Tests
//
//  Created by Serhii Londar on 09.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import UIKit
import CrowdinSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
		let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
                                                          sourceLanguage: "en")
        
        let loginConfig = try! CrowdinLoginConfig(clientId: "XjNxVvoJh6XMf8NGnwuG",
                                             clientSecret: "Dw5TxCKvKQQRcPyAWEkTCZlxRGmcja6AFZNSld6U",
                                             scope: "project.screenshot",
											 redirectURI: "crowdintest://")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(debugEnabled: true)
														.with(loginConfig: loginConfig)
                                                        .with(settingsEnabled: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: { })
		
        return true
    }
}

