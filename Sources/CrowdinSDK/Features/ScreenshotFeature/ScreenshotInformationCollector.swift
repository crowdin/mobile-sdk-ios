//
//  ScreenshotInformationCollector.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import CoreGraphics
#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

#if !os(watchOS)

public struct ControlInformation {
	var key: String
	var rect: CGRect

    public init(key: String, rect: CGRect) {
        self.key = key
        self.rect = rect
    }
}

class ScreenshotInformationCollector {
    static let scale = CWScreen.scale()

	class func captureControlsInformation() -> [ControlInformation] {
        guard let topViewController = ScreenshotFeature.topViewController else { return [] }
        return self.getControlsInformation(from: topViewController.view, rootView: topViewController.view)
	}

    class func getControlsInformation(from view: CWView, rootView: CWView) -> [ControlInformation] {
		var description = [ControlInformation]()
		view.subviews.forEach { subview in
            guard !subview.isHidden && subview.alpha != 0.0 else { return }
			if let label = subview as? CWLabel, let localizationKey = label.localizationKey {
                if let frame = label.superview?.convert(label.frame, to: rootView), rootView.bounds.contains(frame), frame.isValid { // Check wheather control frame is visible on screen.
#if os(OSX)
                    let x = frame.origin.x * scale
                    let y = (rootView.bounds.size.height - frame.origin.y - frame.size.height) * scale
                    let newRect = CGRect(x: x, y: y, width: frame.size.width * scale, height: frame.size.height * scale)
                    description.append(ControlInformation(key: localizationKey, rect: newRect))
#elseif os(iOS) || os(tvOS)
                    let newRect = CGRect(x: frame.origin.x * scale, y: frame.origin.y * scale, width: frame.size.width * scale, height: frame.size.height * scale)
                    description.append(ControlInformation(key: localizationKey, rect: newRect))
#endif
                }
			}
            description.append(contentsOf: getControlsInformation(from: subview, rootView: rootView))
		}
        return description
	}
}

#endif
