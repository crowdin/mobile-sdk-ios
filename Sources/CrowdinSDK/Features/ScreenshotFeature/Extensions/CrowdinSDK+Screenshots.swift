//
//  CrowdinSDK+ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

#if !os(watchOS)

/// Extension that adds screenshot capture functionality to CrowdinSDK
extension CrowdinSDK {
    /// Initializes the screenshot feature with the current SDK configuration.
    /// This method sets up the screenshot feature if it's enabled in the configuration,
    /// creating necessary uploaders and processors, and configuring method swizzling.
    @objc class func initializeScreenshotFeature() {
        guard let config = CrowdinSDK.config else { return }
        if config.screenshotsEnabled {
            let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
            let screenshotUploader = CrowdinScreenshotUploader(organizationName: config.crowdinProviderConfig?.organizationName, hash: crowdinProviderConfig.hashString, sourceLanguage: crowdinProviderConfig.sourceLanguage)
            ScreenshotFeature.shared = ScreenshotFeature(screenshotUploader: screenshotUploader, screenshotProcessor: CrowdinScreenshotProcessor())
            swizzleControlMethods()
        }
    }
    
    /// Captures a screenshot of the current top view controller and upload it to Crowdin.
    /// - Parameters:
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully captured and uploaded.
    ///   - errorHandler: A closure to be called if an error occurs during the process.
    ///                   The closure receives an optional Error parameter indicating what went wrong.
    public class func captureScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshotFeature = ScreenshotFeature.shared else {
            errorHandler(NSError(domain: "Screenshots feature disabled", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotFeature.captureScreenshot(name: name, success: success, errorHandler: errorHandler)
    }
    
    /// Captures a screenshot of a specific view and upload it to Crowdin.
    /// - Parameters:
    ///   - view: The view to capture in the screenshot.
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully captured and uploaded.
    ///   - errorHandler: A closure to be called if an error occurs during the process.
    ///                   The closure receives an optional Error parameter indicating what went wrong.
    public class func captureScreenshot(view: View, name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshotFeature = ScreenshotFeature.shared else {
            errorHandler(NSError(domain: "Screenshots feature disabled", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotFeature.captureScreenshot(view: view, name: name, success: success, errorHandler: errorHandler)
    }
    
    /// Captures a screenshot of the current top view controller and updates it if it already exists in Crowdin.
    /// If several screnshots with passed name exist it will update the newest one.
    /// If screenshot with fiven name not exist new one will be created.
    /// - Parameters:
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully captured and updated.
    ///   - errorHandler: A closure to be called if an error occurs during the process.
    ///                   The closure receives an optional Error parameter indicating what went wrong.
    public class func captureAndUpdateScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshotFeature = ScreenshotFeature.shared else {
            errorHandler(NSError(domain: "Screenshots feature disabled", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotFeature.captureScreenshot(name: name, success: success, errorHandler: errorHandler)
    }
    
    /// Captures a screenshot of a specific view and updates it if it already exists in Crowdin.
    /// If several screnshots with passed name exist it will update the newest one.
    /// If screenshot with fiven name not exist new one will be created.
    /// - Parameters:
    ///   - view: The view to capture in the screenshot.
    ///   - name: The name to be assigned to the screenshot.
    ///   - success: A closure to be called when the screenshot is successfully captured and updated.
    ///   - errorHandler: A closure to be called if an error occurs during the process.
    ///                   The closure receives an optional Error parameter indicating what went wrong.
    public class func captureAndUpdateScreenshot(view: View, name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshotFeature = ScreenshotFeature.shared else {
            errorHandler(NSError(domain: "Screenshots feature disabled", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }
        screenshotFeature.captureScreenshot(view: view, name: name, success: success, errorHandler: errorHandler)
    }
}

#endif
