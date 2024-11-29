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
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                          sourceLanguage: Self.sourceLanguage)
        
        let crowdinSDKConfig = CrowdinSDKConfig.config()
            .with(crowdinProviderConfig: crowdinProviderConfig)
            .with(accessToken: Self.accessToken)
            .with(screenshotsEnabled: true)
        
        CrowdinSDK.startWithConfigSync(crowdinSDKConfig)
    }
    
    override class func tearDown() {
        CrowdinSDK.deintegrate()
    }
    
    @MainActor
    func testScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // MAIN SCREEN
        var result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "MAIN_SCREEN", image: XCUIScreen.main.screenshot().image, application: app)
        XCTAssertNil(result.1)
        
        // ADD LIST
        app.otherElements.buttons.element(matching: .button, identifier: "addListBtn").tap()
        
        result = CrowdinSDK.captureOrUpdateScreenshotSync(name: "ADD_LIST", image: XCUIScreen.main.screenshot().image, application: app)
        XCTAssertNil(result.1)
    }
}
