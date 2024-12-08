//
//  AppleRemindersUITestsLaunchTests.swift
//  AppleRemindersUITests
//
//  Created by Serhii Londar on 26.11.2024.
//  Copyright © 2024 Josh R. All rights reserved.
//

import XCTest
import CrowdinSDK
#if canImport(CrowdinXCTestScreenshots)
import CrowdinXCTestScreenshots
#endif

final class AppleRemindersUITestsCrowdinScreenhsotTests: XCTestCase {
    private static let distributionHash = "distribution_hash"
    private static let sourceLanguage = "source_language"
    private static let accessToken = "access_token"
    
    override class func setUp() {
        // Requires to start SDK before running testScreenshots as it needs to get all supported localizations from Crowdin.
        startSDK(localization: sourceLanguage)
    }
    
    class func startSDK(localization: String) {
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                          sourceLanguage: Self.sourceLanguage)
        
        let crowdinSDKConfig = CrowdinSDKConfig.config()
            .with(crowdinProviderConfig: crowdinProviderConfig)
            .with(accessToken: Self.accessToken)
            .with(screenshotsEnabled: true)
        
        CrowdinSDK.currentLocalization = localization
        
        CrowdinSDK.startWithConfigSync(crowdinSDKConfig)
    }
    
    override class func tearDown() {
        CrowdinSDK.deintegrate()
    }
    
    @MainActor
    func testScreenshots() throws {
        XCTAssert(CrowdinSDK.inSDKLocalizations.count > 0, "At least one target language should be set up in Crowdin.")
        
        let app = XCUIApplication()
        // Pass selected localization in test to the app.
        app.launchArguments = ["UI_TESTING", "CROWDIN_LANGUAGE_CODE=\(Self.sourceLanguage)"]
        app.launch()
        
        let addListBtn = app.otherElements.buttons.element(matching: .button, identifier: "addListBtn")
        _ = app.waitForExistence(timeout: 5) // Timeout for app to start SDK and show UI.
        
        // MAIN SCREEN
        var result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "MAIN_SCREEN_\(Self.sourceLanguage)", image: XCUIScreen.main.screenshot().image, application: app)
        XCTAssertNil(result.error)
        
        // ADD LIST
        addListBtn.tap()
        
        result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "ADD_LIST_\(Self.sourceLanguage)", image: XCUIScreen.main.screenshot().image, application: app)
        XCTAssertNil(result.error)
    }
    
    @MainActor
    func testScreenshotsForAllLocalizations() throws {
        XCTAssert(CrowdinSDK.inSDKLocalizations.count > 0, "At least one target language should be set up in Crowdin.")
        
        for localization in CrowdinSDK.inSDKLocalizations {
            // Start SKD inside tests for selected localization.
            Self.startSDK(localization: localization)
            
            let app = XCUIApplication()
            // Pass selected localization in test to the app.
            app.launchArguments = ["UI_TESTING", "CROWDIN_LANGUAGE_CODE=\(localization)"]
            app.launch()
            
            let addListBtn = app.otherElements.buttons.element(matching: .button, identifier: "addListBtn")
            _ = app.waitForExistence(timeout: 5) // Timeout for app to start SDK and show UI.
            
            // MAIN SCREEN
            var result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "MAIN_SCREEN_\(localization)", image: XCUIScreen.main.screenshot().image, application: app)
            XCTAssertNil(result.error)
            
            // ADD LIST
            addListBtn.tap()
            
            result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "ADD_LIST_\(localization)", image: XCUIScreen.main.screenshot().image, application: app)
            XCTAssertNil(result.error)
        }
    }
}
