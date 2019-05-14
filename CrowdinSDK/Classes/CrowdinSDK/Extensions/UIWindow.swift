//
//  UIWindow.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/14/19.
//

import Foundation

extension UIWindow {
    open func topViewController() -> UIViewController? {
        return self.rootViewController?.topViewController()
    }
}
