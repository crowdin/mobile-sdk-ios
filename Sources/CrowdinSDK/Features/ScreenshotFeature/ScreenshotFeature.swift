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

/// A feature class that handles screenshot capture and upload functionality for the Crowdin SDK.
class ScreenshotFeature {
    /// Shared instance of the ScreenshotFeature.
    static var shared: ScreenshotFeature?

    /// The uploader responsible for sending screenshots to Crowdin.
    var screenshotUploader: ScreenshotUploader

    /// The processor that handles screenshot processing operations.
    var screenshotProcessor: ScreenshotProcessor

    /// Initializes a new instance of ScreenshotFeature.
    /// - Parameters:
    ///   - screenshotUploader: The uploader instance responsible for sending screenshots to Crowdin.
    ///   - screenshotProcessor: The processor instance that handles screenshot processing operations.
    init(screenshotUploader: ScreenshotUploader, screenshotProcessor: ScreenshotProcessor) {
        self.screenshotUploader = screenshotUploader
        self.screenshotProcessor = screenshotProcessor
    }

    /// Captures a screenshot of the top view controller and uploads it to Crowdin.
    /// - Parameters:
    ///   - name: The name to be assigned to the screenshot. If the name doesn't end with .png, the extension will be automatically added.
    ///   - success: A closure to be called when the screenshot is successfully captured and uploaded.
    ///   - errorHandler: A closure to be called when an error occurs during the process. The closure receives an optional Error parameter.
    func captureScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard name.validateScreenshotName() else {
            errorHandler(NSError(domain: String.screenshotValidationError(), code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        var name = name
        if !name.hasSuffix(FileType.png.extension) {
            name += FileType.png.extension
        }
        guard let vc = ScreenshotFeature.topViewController else { return }
        self.captureScreenshot(view: vc.view, name: name, success: success, errorHandler: errorHandler)
    }

    /// Captures a screenshot of a specific view and uploads it to Crowdin.
    /// - Parameters:
    ///   - view: The view to capture in the screenshot.
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully captured and uploaded.
    ///   - errorHandler: A closure to be called when an error occurs during the process. The closure receives an optional Error parameter.
    func captureScreenshot(view: CWView, name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshot = view.screenshot else {
            errorHandler(NSError(domain: "Unable to create screenshot.", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotUploader.prepare { error in
            if let error {
                errorHandler(error)
                return
            }

            let controlsInformation = ScreenshotInformationCollector.getControlsInformation(from: view, rootView: view)
            self.screenshotUploader.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
        }
    }

    func updateOrUploadScreenshot(name: String, success: @escaping ((ScreenshotUploadResult) -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard name.validateScreenshotName() else {
            errorHandler(NSError(domain: String.screenshotValidationError(), code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        var name = name
        if !name.hasSuffix(FileType.png.extension) {
            name += FileType.png.extension
        }
        guard let vc = ScreenshotFeature.topViewController else { return }
        updateOrUploadScreenshot(view: vc.view, name: name, success: success, errorHandler: errorHandler)
    }

    /// Updates an existing screenshot or uploads a new one if it doesn't exist.
    /// - Parameters:
    ///   - view: The view to capture in the screenshot.
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully updated or uploaded.
    ///   - errorHandler: A closure to be called when an error occurs during the process. The closure receives an optional Error parameter.
    func updateOrUploadScreenshot(view: CWView, name: String, success: @escaping ((ScreenshotUploadResult) -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshot = view.screenshot else {
            errorHandler(NSError(domain: "Unable to create screenshot from view.", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotUploader.prepare { error in
            if let error {
                errorHandler(error)
                return
            }
            let controlsInformation = ScreenshotInformationCollector.getControlsInformation(from: view, rootView: view)
            self.screenshotUploader.updateOrUploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
        }
    }

    func captureScreenshot(name: String, screenshot: CWImage, controlsInformation: [ControlInformation], success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        if let error = screenshotUploader.prepareSync() {
            errorHandler(error)
            return
        }
        var name = name
        if !name.hasSuffix(FileType.png.extension) {
            name += FileType.png.extension
        }
        self.screenshotUploader.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
    }

    func captureOrUpdateScreenshot(
        name: String,
        screenshot: CWImage,
        controlsInformation: [ControlInformation],
        success: @escaping ((ScreenshotUploadResult) -> Void),
        errorHandler: @escaping ((Error?) -> Void)
    ) {
        if let error = screenshotUploader.prepareSync() {
            errorHandler(error)
            return
        }
        var name = name
        if !name.hasSuffix(FileType.png.extension) {
            name += FileType.png.extension
        }
        self.screenshotUploader.updateOrUploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
    }

    /// Returns the top view controller of the application's key window.
    /// - Returns: The top most view controller currently displayed, or nil if none is found.
    class var topViewController: CWViewController? {
#if os(OSX)
        return NSApplication.shared.keyWindow?.contentViewController
#elseif os(iOS) || os(tvOS)
    guard let window = UIApplication.shared.cw_KeyWindow, let topViewController = window.topViewController() else { return nil }
    return topViewController
#endif
    }
}

#endif
