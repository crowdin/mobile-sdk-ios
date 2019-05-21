//
//  UIWindow.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/14/19.
//

import Foundation

extension UIWindow {
    var topViewController: UIViewController? {
        return self.rootViewController?.topViewController()
    }
}

extension UIWindow {
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, self.screen.scale)
        defer { UIGraphicsEndImageContext() }
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
