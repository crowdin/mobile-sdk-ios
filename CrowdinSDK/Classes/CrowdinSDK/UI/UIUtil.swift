//
//  UIUtil.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

class UIUtil {
    static let shared: UIUtil = UIUtil()
    
    private var controls = NSHashTable<AnyObject>.weakObjects()
    
    func subscribe(control: Refreshable) {
        controls.add(control)
    }
    
    var windows: [UIWindow] { return UIApplication.shared.windows }
    
    var window: UIWindow? { return UIApplication.shared.keyWindow }
    
    func refresh() {
        self.controls.allObjects.forEach { (control) in
            if let refreshable = control as? Refreshable {
                refreshable.refresh()
            }
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
