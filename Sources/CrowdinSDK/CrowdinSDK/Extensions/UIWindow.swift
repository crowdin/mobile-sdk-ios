//
//  UIWindow.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/14/19.
//

#if os(iOS) || os(tvOS)

import UIKit

// MARK: - Extension for window screenshot creation.
extension UIView {
    /// Current window screenshot.
    var screenshot: UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, scale)
        defer { UIGraphicsEndImageContext() }
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#endif
