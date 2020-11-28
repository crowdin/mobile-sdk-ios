//
//  UIViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/16/19.
//

import Foundation

// MARK: - Custom view controller presentation and dismiss.
public extension UIViewController {
    private static let alertWindowAssociation = ObjectAssociation<UIWindow>()
    private var alertWindow: UIWindow? {
        get { return UIViewController.alertWindowAssociation[self] }
        set { UIViewController.alertWindowAssociation[self] = newValue }
    }
    
    private static let topWindowAssociation = ObjectAssociation<UIWindow>()
    private var topWindow: UIWindow? {
        get { return UIViewController.topWindowAssociation[self] }
        set { UIViewController.topWindowAssociation[self] = newValue }
    }
    
    /// Custom view controller presentation. View controller presenter on new window over all existing windows. To dismiss it cw_dismiss() method should be used.
    /// https://stackoverflow.com/a/51723032/3697225
    @objc func cw_present() {
        self.alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
        self.topWindow = UIApplication.shared.keyWindow
        
        let viewController = UIViewController()
        self.alertWindow?.rootViewController = viewController

        if let topWindow = topWindow {
            self.alertWindow?.windowLevel = topWindow.windowLevel + 1
        }

        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
    /// Dissmiss view controller presenter with cw_present() method.
    @objc func cw_dismiss() {
        self.dismiss(animated: false, completion: nil)
        self.alertWindow?.resignKey()
        self.alertWindow?.isHidden = true
        self.alertWindow = nil
        self.topWindow?.makeKeyAndVisible()
        self.topWindow = nil
    }
}
