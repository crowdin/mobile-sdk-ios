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
    
    func captureScreenshot() -> UIImage? {
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
