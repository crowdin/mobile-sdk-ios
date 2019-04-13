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
