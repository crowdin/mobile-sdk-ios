
//
//  ScreenshotProcessor.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

public protocol ScreenshotProcessor {
	func process(screenshot: UIImage) -> UIImage
}

class CrowdinScreenshotProcessor {
	func process(screenshot: UIImage) -> UIImage {
		return screenshot
	}
}
