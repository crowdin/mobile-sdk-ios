//
//  UIViewController+Shake.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/27/19.
//

import UIKit

extension UIViewController {
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if ScreenshotFeature.shared?.type == .shake {
            ScreenshotFeature.shared?.captureScreenshot()
        }
    }
}
