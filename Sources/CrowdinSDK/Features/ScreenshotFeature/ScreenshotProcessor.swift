//
//  ScreenshotProcessor.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

#if !os(watchOS)

public protocol ScreenshotProcessor {
	func process(screenshot: CWImage, with controlsInfo: [ControlInformation]) -> CWImage
}

class CrowdinScreenshotProcessor: ScreenshotProcessor {
	func process(screenshot: CWImage, with controlsInfo: [ControlInformation]) -> CWImage {
		return screenshot
	}
}

#endif
