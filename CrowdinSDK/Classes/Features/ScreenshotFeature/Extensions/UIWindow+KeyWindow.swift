//
//  UIWindow+KeyWindow.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 18.12.2020.
//

import UIKit

extension UIApplication {
    var cw_KeyWindow: UIWindow? {
        return windows.first(where: { $0.isKind(of: SettingsWindow.self) == false })
    }
}

extension UIWindow {
    var rootVC: UIViewController? {
        guard let keyWindow = UIApplication.shared.cw_KeyWindow, let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return rootViewController
    }

    func topViewController(controller: UIViewController? = UIApplication.shared.cw_KeyWindow?.rootVC) -> UIViewController? {
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }

            if let tabController = controller as? UITabBarController {
                if let selectedViewController = tabController.selectedViewController {
                    return topViewController(controller: selectedViewController)
                }
            }

            if let presentedViewController = controller?.presentedViewController {
                return topViewController(controller: presentedViewController)
            }

            return controller
        }
}
