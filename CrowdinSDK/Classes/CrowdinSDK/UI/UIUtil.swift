//
//  UIUtil.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

class UIUtil {
    var windows: [UIWindow] {
        return UIApplication.shared.windows
    }
    
    var window: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    static let shared: UIUtil = UIUtil()
    
    func reload() {
        self.refreshWindows()
    }
    
    func refreshWindows() {
        self.windows.forEach({ self.refresh(window: $0) })
    }
    
    func refreshWindow() {
        if let window = self.window {
            self.refresh(window: window)
        }
    }
    
    func refresh(window: UIWindow) {
        window.subviews.forEach({ self.refresh(view: $0) })
    }
    
    func refresh(view: UIView) {
        view.subviews.forEach { (subview) in
            if let label = subview as? UILabel {
                self.refresh(label: label)
            } else if let button = subview as? UIButton {
                self.refresh(button: button)
            } else {
                self.refresh(view: subview)
            }
        }
    }
    
    func refresh(label: UILabel) {
        if let key = label.localizationKey, let values = label.localizationValues as? [CVarArg] {
            label.text = String(format: NSLocalizedString(key, comment: ""), arguments: values)
        } else if let key = label.localizationKey {
            label.text = NSLocalizedString(key, comment: "")
        }
        label.setNeedsDisplay()
    }
    
    func refresh(button: UIButton) {
        if let key = button.localizationKeys?[button.state.rawValue] {
            button.setTitle(NSLocalizedString(key, comment: ""), for: button.state)
        }
    }
    
    func captureScreenshot() -> UIImage? {
        guard let window = self.window else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.frame.size, true, window.screen.scale)
        defer { UIGraphicsEndImageContext() }
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
