//
//  UIViewController+Shake.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/27/19.
//

import UIKit

extension UIViewController {
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard let screnshot = UIUtil.shared.captureScreenshot() else { return }
        let storyboard = UIStoryboard(name: "SaveScreenshotVC", bundle: Bundle(for: SaveScreenshotVC.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "SaveScreenshotVC") as! SaveScreenshotVC
        vc.screenshot = screnshot
        UIUtil.shared.window?.rootViewController?.present(vc, animated: true, completion: { })
    }
}
