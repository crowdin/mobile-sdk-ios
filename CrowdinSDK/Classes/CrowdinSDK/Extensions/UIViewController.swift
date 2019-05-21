//
//  UIViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/16/19.
//

import Foundation

extension UIViewController {
    func cw_present(viewController: UIViewController) {
        self.view.addSubview(viewController.view)
        viewController.view.frame = self.view.frame
        self.view.bringSubviewToFront(viewController.view)
    }
    
    func cw_dismiss() {
        self.view.removeFromSuperview()
    }
}

extension UIViewController {
    func topViewController() -> UIViewController? {
        return findTopViewController(self)
    }
    
    fileprivate func findTopViewController(_ base: UIViewController?) -> UIViewController? {
        guard let base = base else {
            return nil
        }
        
        if let nav = base as? UINavigationController {
            return findTopViewController(nav.visibleViewController)
        }
        else if let tab = base as? UITabBarController {
            if let selectedViewController = tab.selectedViewController {
                return findTopViewController(selectedViewController)
            }
        }
        else if let presentedViewController = base.presentedViewController {
            return findTopViewController(presentedViewController);
        }
        else if base.children.isEmpty == false {
            if let lastViewController = base.children.reversed().filter({ (vc) -> Bool in
                return vc.isViewLoaded
                    && (vc.view.isHidden == false)
                    && (base.view.bounds == vc.view.frame)
            }).first {
                return findTopViewController(lastViewController);
            }
        }
        
        return base
    }
}
