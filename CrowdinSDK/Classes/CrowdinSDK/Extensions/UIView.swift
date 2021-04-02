//
//  UIView.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 3/27/21.
//

import Foundation

// MARK: - Custom view presentation and dismissing.
public extension UIView {
    private static let viewWindowAssociation = ObjectAssociation<PassTroughWindow>()
    private var viewWindow: PassTroughWindow? {
        get { return UIView.viewWindowAssociation[self] }
        set { UIView.viewWindowAssociation[self] = newValue }
    }
    
    private static let topViewWindowAssociation = ObjectAssociation<PassTroughWindow>()
    private var topViewWindow: PassTroughWindow? {
        get { return UIView.topViewWindowAssociation[self] }
        set { UIView.topViewWindowAssociation[self] = newValue }
    }
    
    @objc func cw_present() {
        self.topViewWindow = UIApplication.shared.keyWindow as? PassTroughWindow
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene {
                self.viewWindow = PassTroughWindow(windowScene: windowScene)
            } else {
                self.viewWindow = PassTroughWindow.init(frame: UIScreen.main.bounds)
            }
        } else {
            self.viewWindow = PassTroughWindow.init(frame: UIScreen.main.bounds)
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
