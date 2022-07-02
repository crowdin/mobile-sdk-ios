
//
//  ScreenshotProcessor.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

public protocol ScreenshotProcessor {
	func process(screenshot: Image, with controlsInfo: [ControlInformation]) -> Image
}

class CrowdinScreenshotProcessor: ScreenshotProcessor {
	func process(screenshot: Image, with controlsInfo: [ControlInformation]) -> Image {
		return screenshot
	}
}
