//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

enum ScreenshotFeatureType {
    case shake
}

class ScreenshotFeature {
    var type: ScreenshotFeatureType = .shake
    
    static let shared = ScreenshotFeature()
    
    var windows: [UIWindow] { return UIApplication.shared.windows }
    
    var window: UIWindow? { return UIApplication.shared.keyWindow }
    
    func captureScreenshot() -> UIImage? {
        guard let window = self.window else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.frame.size, true, window.screen.scale)
        defer { UIGraphicsEndImageContext() }
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
