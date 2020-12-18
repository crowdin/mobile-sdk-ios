//
//  ScreenshotInformationCollector.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

public struct ControlInformation {
	var key: String
	var rect: CGRect
}

class ScreenshotInformationCollector {
	class func captureControlsInformation() -> [ControlInformation] {
		guard let window = UIApplication.shared.cw_KeyWindow else { return [] }
//        guard let vc = window.rootViewController else { return [] }
        let values = self.getControlsInformation(from: window)
		let koef = window.screen.scale
		var returnValue = [ControlInformation]()
		values.forEach { value in
			let rect = value.rect
			let key = value.key
			if window.bounds.contains(rect), rect.isValid { // Check wheather control frame is visible on screen.
				let newRect = CGRect(x: rect.origin.x * koef, y: rect.origin.y * koef, width: rect.size.width * koef, height: rect.size.height * koef)
				returnValue.append(ControlInformation(key: key, rect: newRect))
			}
		}
		return returnValue
	}
	
	class func getControlsInformation(from view: UIView) -> [ControlInformation] {
		var description = [ControlInformation]()
		view.subviews.forEach { (view) in
            guard !view.isHidden && view.alpha != 0.0 else { return }
			if let label = view as? UILabel, let localizationKey = label.localizationKey {
				if let frame = label.superview?.convert(label.frame, to: UIApplication.shared.cw_KeyWindow) {
					description.append(ControlInformation(key: localizationKey, rect: frame))
				}
			}
			description.append(contentsOf: getControlsInformation(from: view))
		}
		return description
	}
}
