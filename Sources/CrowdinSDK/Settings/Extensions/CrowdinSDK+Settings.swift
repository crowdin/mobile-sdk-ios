//
//  CrowdinSDK+ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS)

extension CrowdinSDK {
    @objc class func initializeSettings() {
        guard let config = CrowdinSDK.config else { return }
        if config.settingsEnabled {
            self.showSettings()
        }
    }

    public class func showSettings() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let settingsView = SettingsView.shared {
                if #available(iOS 13.0, tvOS 13.0, *) {
                    if settingsView.settingsWindow.windowScene == nil {
                        settingsView.settingsWindow.windowScene = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
                    }
                }
                settingsView.settingsWindow.isHidden = false
                settingsView.center = CGPoint(x: 100, y: 100)
                settingsView.settingsWindow.settingsView = settingsView
            }
        }
    }
}

#endif
