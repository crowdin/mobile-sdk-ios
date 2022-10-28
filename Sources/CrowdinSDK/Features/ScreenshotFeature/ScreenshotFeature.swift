//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import Foundation
#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

#if !os(watchOS)

class ScreenshotFeature {
    static var shared: ScreenshotFeature?
	var screenshotUploader: ScreenshotUploader
	var screenshotProcessor: ScreenshotProcessor
	
	init(screenshotUploader: ScreenshotUploader, screenshotProcessor: ScreenshotProcessor) {
		self.screenshotUploader = screenshotUploader
		self.screenshotProcessor = screenshotProcessor
	}
	
    func captureScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let window = UIApplication.shared.cw_KeyWindow, let vc = window.topViewController() else {
			errorHandler(NSError(domain: "Unable to create screenshot.", code: defaultCrowdinErrorCode, userInfo: nil))
			return
		}
        var name = name
        if !name.hasSuffix(FileType.png.extension) {
            name += FileType.png.extension
        }
        guard let vc = ScreenshotFeature.topViewController else { return }
        self.captureScreenshot(view: vc.view, name: name, success: success, errorHandler: errorHandler)
    }
    
    func captureScreenshot(view: View, name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshot = view.screenshot else {
            errorHandler(NSError(domain: "Unable to create screenshot.", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        let controlsInformation = ScreenshotInformationCollector.getControlsInformation(from: view, rootView: view)
        screenshotUploader.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
    }
    
    class var topViewController: ViewController? {
#if os(OSX)
        return NSApplication.shared.keyWindow?.contentViewController
#elseif os(iOS) || os(tvOS)
    guard let window = UIApplication.shared.cw_KeyWindow, let topViewController = window.topViewController() else { return nil }
    return topViewController
#endif
    }
}

#endif
