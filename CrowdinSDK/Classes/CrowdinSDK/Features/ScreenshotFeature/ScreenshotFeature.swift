//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

enum ScreenshotFeatureType {
    case shake
}

class ScreenshotFeature {
    var type: ScreenshotFeatureType = .shake
    
    static var shared: ScreenshotFeature?
    
    var windows: [UIWindow] { return UIApplication.shared.windows }
    
    var window: UIWindow? { return UIApplication.shared.keyWindow }
    
    func captureScreenshot() {
        guard let screenshot = self.screenshot else { return }
        let storyboard = UIStoryboard(name: "SaveScreenshotVC", bundle: Bundle(for: SaveScreenshotVC.self))
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SaveScreenshotVC") as? SaveScreenshotVC else { return }
        vc.screenshot = screenshot
        vc.descriptionText = captureDescription()
        // TODO: Add screenshot VC as subview to avoid issues with already presented VC.
        ScreenshotFeature.shared?.window?.rootViewController?.present(vc, animated: true, completion: { })
    }
    
    var screenshot: UIImage? {
        guard let window = self.window else { return nil }
        self.addBorders(to: window)
        
        UIGraphicsBeginImageContextWithOptions(window.frame.size, true, window.screen.scale)
        defer { UIGraphicsEndImageContext() }
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        
        self.removeBorders(from: window)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func captureDescription() -> String {
        guard let window = self.window else { return "" }
        return self.getDescription(from: window)
    }
    
    func getDescription(from view: UIView) -> String {
        var description = ""
        view.subviews.forEach { (view) in
            if let label = view as? UILabel, let localizationKey = label.localizationKey {
                if let frame = label.superview?.convert(label.frame, to: window), let text = label.text {
                    description +=  "\(localizationKey) :\nText - \(text)\nFrame - \(frame.debugDescription)\n\n"
                }
            }
            description += getDescription(from: view)
        }
        return description
    }
    
    func addBorders(to view: UIView) {
        view.subviews.forEach { (view) in
            if let label = view as? UILabel, label.localizationKey != nil {
                label.layer.borderColor = UIColor.red.cgColor
                label.layer.borderWidth = 2
                label.setNeedsDisplay()
            }
            addBorders(to: view)
        }
    }
    
    func removeBorders(from view: UIView) {
        view.subviews.forEach { (view) in
            if let label = view as? UILabel, label.localizationKey != nil {
                label.layer.borderColor = UIColor.clear.cgColor
                label.layer.borderWidth = 0
                label.setNeedsDisplay()
            }
            removeBorders(from: view)
        }
    }
}

extension UIViewController {
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
                    && (vc.view.alpha >= 0.05)
                    && (base.view.bounds == vc.view.frame)
            }).first {
                return findTopViewController(lastViewController);
            }
        }
        
        return base
    }
    
    fileprivate func topViewController() -> UIViewController? {
        return findTopViewController(self)
    }
}

extension UIWindow {
    open func topViewController() -> UIViewController? {
        return self.rootViewController?.topViewController()
    }
}
