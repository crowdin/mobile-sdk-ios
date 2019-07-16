//
//  UIViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/16/19.
//

import Foundation

// MARK: - Custom view controller presentation and dismiss.
extension UIViewController {
    /// Custom view controller presentation.
    ///
    /// - Parameter viewController: View controller to present.
    func cw_present(viewController: UIViewController) {
        viewController.loadViewIfNeeded()
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.frame = self.view.bounds
        self.view.bringSubviewToFront(viewController.view)
    }
    
    /// Dismiss custom presented view controller.
    func cw_dismiss() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
}
