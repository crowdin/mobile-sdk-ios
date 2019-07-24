//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

class ScreenshotFeature {
    static var shared: ScreenshotFeature?
	var screenshotUploader: ScreenshotUploader
	var screenshotProcessor: ScreenshotProcessor
	
	init(screenshotUploader: ScreenshotUploader, screenshotProcessor: ScreenshotProcessor) {
		self.screenshotUploader = screenshotUploader
		self.screenshotProcessor = screenshotProcessor
	}
	
    func captureScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
		guard let screenshot = UIApplication.shared.keyWindow?.screenshot else {
			errorHandler(NSError(domain: "Unable to create screenshot.", code: defaultCrowdinErrorCode, userInfo: nil))
			return
		}
		let controlsInformation = ScreenshotInformationCollector.captureControlsInformation()
		screenshotUploader.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
    }
}
