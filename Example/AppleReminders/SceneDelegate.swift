//
//  SceneDelegate.swift
//  AppleReminders
//
//  Created by Josh R on 1/24/20.
//  Copyright © 2020 Josh R. All rights reserved.
//

import UIKit
import CrowdinSDK
import netfox

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // MARK: - Configuration
    
    private static let distributionHash = "distribution_hash"
    private static let sourceLanguage = "source_language"
    private static let accessToken = "access_token"
    
    private static let clientId = "client_id"
    private static let clientSecret = "client_secret"
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Check for launch arguments
        
        NFX.sharedInstance().start()
        
        let arguments = ProcessInfo.processInfo.arguments
        
        let isTesting = arguments.contains("UI_TESTING")

        let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                          sourceLanguage: Self.sourceLanguage)
        
        if isTesting, let locale = arguments.first(where: { $0.contains("CROWDIN_LANGUAGE_CODE") })?.split(separator: "=").last.map({ String($0) }) {
            print(locale)
            
            let crowdinSDKConfig = CrowdinSDKConfig.config()
                .with(crowdinProviderConfig: crowdinProviderConfig)
                .with(accessToken: Self.accessToken)
                .with(screenshotsEnabled: true)
            
            CrowdinSDK.currentLocalization = locale
            
            CrowdinSDK.startWithConfig(crowdinSDKConfig) {
                DispatchQueue.main.async {
                    guard let windowScene = (scene as? UIWindowScene) else { return }
                    
                    let navController = UINavigationController(rootViewController: MainVC())

                    self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                    self.window?.windowScene = windowScene
                    self.window?.rootViewController = navController
                    self.window?.makeKeyAndVisible()
                }
            }
            
            return
            
        } else {
            let loginConfig = try! CrowdinLoginConfig(clientId: Self.clientId,
                                                      clientSecret: Self.clientSecret,
                                                      scope: "project")
            let crowdinSDKConfig = CrowdinSDKConfig.config()
                .with(crowdinProviderConfig: crowdinProviderConfig)
                .with(loginConfig: loginConfig)
                .with(accessToken: Self.accessToken)
                .with(settingsEnabled: true)
                .with(realtimeUpdatesEnabled: true)
                .with(screenshotsEnabled: true)
            
            CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: { })
            
            // Now new log message comes as callback
            CrowdinSDK.setOnLogCallback { logMessage in
                print("LOG MESSAGE - \(logMessage)")
            }
        }
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        //Create Nav Controller
        let navController = UINavigationController(rootViewController: MainVC())

        //source: https://www.youtube.com/watch?v=Htn4h51BQsk
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        CrowdinSDK.handle(url: url)
    }
}

