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
        
        FirebaseApp.configure()
        CrowdinSDK.start(with: FirebaseLocalizationProvider(path: "extracted_example"))
//        CrowdinSDK.start(with: LocalLocalizationProvider())
        
        // Setup CrowdinSDK with crowdin localization provider.
//        CrowdinSDK.start(with: "66f02b964afeb77aea8d191e68748abc", stringsFileNames: ["Localizable.strings", "Base.strings"], pluralsFileNames: ["Localizable.stringsdict", "Base.stringsdict"], projectIdentifier: "content-er4", projectKey: "af3d3deb8d45b7f7ac4e58c83ca2bc0c")
        
        CrowdinSDK.extractAllLocalization()
        
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

