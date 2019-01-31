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
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CrowdinSDK.start()
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var panelsVC = FAPanelController()
        
        let mainVC = UIStoryboard(name: "MainViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let mainNC = UINavigationController(rootViewController: mainVC)
        
        
        let menuVC = UIStoryboard(name: "MenuVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        
        panelsVC = panelsVC.center(mainNC).left(menuVC)
        
        self.window?.rootViewController = panelsVC
        self.window?.makeKeyAndVisible()
        
        self.subscribe()
        
        return true
    }
    
    func subscribe() {
        FireTiny.shared.subscribe(nil) { (data) in
            if let data = data {
                let dictionary = data as! [String: Any]
                dictionary.keys.forEach({ (key) in
                    let translation = dictionary[key] as! [String: String]
                    let data = try! JSONEncoder().encode(translation)
                    try! data.write(to: URL(fileURLWithPath: self.documentsPath + "/org.crowdin.demo.CrowdinSDK.Crowdin/\(key).json"))
                })
                CrowdinSDK.refreshUI()
            }
        }
    }
}

