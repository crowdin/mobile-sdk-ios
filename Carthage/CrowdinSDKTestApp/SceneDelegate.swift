//
//  SceneDelegate.swift
//  CrowdinSDKTestApp
//
//  Created by Nazar Yavornytskyy on 7/8/21.
//

import UIKit
import CrowdinSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let distributionHash = "c532c61daef5739f0096168p9ys"
    private let sourceLanguage = "source_language"
    
    private let clientId = "9iNCAuUX6qmfWfCEWBTG"
    private let clientSecret = "Vocz0soPiYVxZFIDMl8arlqldpnN6negwHZmxS3J"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: distributionHash,
                                                          sourceLanguage: sourceLanguage)
        let loginConfig = try! CrowdinLoginConfig(clientId: clientId,
                                                  clientSecret: clientSecret,
                                                  scope: "project")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
            .with(loginConfig: loginConfig)
            .with(settingsEnabled: true)
            .with(realtimeUpdatesEnabled: true)
            .with(screenshotsEnabled: true)
        
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: { })
        // Now new log message comes as callback
        CrowdinSDK.setOnLogCallback { logMessage in
            print("LOG MESSAGE - \(logMessage)")
        }
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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


}

