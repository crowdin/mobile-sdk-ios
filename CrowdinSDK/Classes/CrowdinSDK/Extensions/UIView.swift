//
//  UIView.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 3/27/21.
//

import Foundation

// MARK: - Custom view presentation and dismissing.
public extension UIView {
    private static let viewWindowAssociation = ObjectAssociation<UIWindow>()
    private var viewWindow: UIWindow? {
        get { return UIView.viewWindowAssociation[self] }
        set { UIView.viewWindowAssociation[self] = newValue }
    }
    
    private static let topViewWindowAssociation = ObjectAssociation<UIWindow>()
    private var topViewWindow: UIWindow? {
        get { return UIView.topViewWindowAssociation[self] }
        set { UIView.topViewWindowAssociation[self] = newValue }
    }
    
    @objc func cw_present() {
        self.topViewWindow = UIApplication.shared.keyWindow
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene {
                self.viewWindow = UIWindow(windowScene: windowScene)
            } else {
                self.viewWindow = UIWindow.init(frame: UIScreen.main.bounds)
            }
        } else {
            self.viewWindow = UIWindow.init(frame: UIScreen.main.bounds)
        }
        
        let viewController = UIViewController()
        self.viewWindow?.rootViewController = viewController

        if let topWindow = topViewWindow {
            self.viewWindow?.windowLevel = topWindow.windowLevel + 1
        }

        self.viewWindow?.makeKeyAndVisible()
        self.viewWindow?.rootViewController?.view.addSubview(self)
    }
    
    @objc func cw_dismiss() {
        self.viewWindow?.resignKey()
        self.viewWindow?.isHidden = true
        self.viewWindow = nil
        self.topViewWindow?.makeKeyAndVisible()
        self.topViewWindow = nil
    }
}
