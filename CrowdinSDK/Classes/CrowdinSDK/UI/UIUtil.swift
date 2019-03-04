//
//  UIUtil.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

class UIUtil {
    static let shared: UIUtil = UIUtil()
    
    private var labels: NSHashTable<UILabel> = NSHashTable<UILabel>.weakObjects()
    private var buttons: NSHashTable<UIButton> = NSHashTable<UIButton>.weakObjects()
    
    func subscribe(label: UILabel) {
        labels.add(label)
    }
    
    func subscribe(button: UIButton) {
        buttons.add(button)
    }
    
    var windows: [UIWindow] { return UIApplication.shared.windows }
    
    var window: UIWindow? { return UIApplication.shared.keyWindow }
    
    func reload() {
        self.labels.allObjects.forEach({ self.refresh(label: $0) })
        self.buttons.allObjects.forEach({ self.refresh(button: $0) })
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
        // TODO: Plurals and formated string support.
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
