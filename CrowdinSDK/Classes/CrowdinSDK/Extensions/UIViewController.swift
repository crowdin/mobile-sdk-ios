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
