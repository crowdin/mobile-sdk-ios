//
//  AppleRemindersUITestsLaunchTests.swift
//  AppleRemindersUITests
//
//  Created by Serhii Londar on 26.11.2024.
//  Copyright © 2024 Josh R. All rights reserved.
//

import XCTest
import CrowdinSDK

final class AppleRemindersUITestsCrowdinScreenhsotTests: XCTestCase {
    
    private static let distributionHash = "{distribution_hash}}"
    private static let sourceLanguage = "{source_language}"
    private static let accessToken = "{access_token}"
    
    override class func setUp() {
        
    }
    
    override class func tearDown() {
        CrowdinSDK.stop()
        CrowdinSDK.deintegrate()
    }
    
    @MainActor
    func testScreenshots() throws {
        
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: Self.distributionHash,
                                                          sourceLanguage: Self.sourceLanguage)
        
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
            .with(accessToken: Self.accessToken)
            .with(screenshotsEnabled: true)
        
        let setupExpectation = self.expectation(description: "CrowdinSDK setup")
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            setupExpectation.fulfill()
        })
        
        wait(for: [setupExpectation], timeout: 30)

        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        let screenshotExpectation = self.expectation(description: "MAIN_SCREEN screenshot")
        
        CrowdinSDK.captureOrUpdateScreenshot(name: "MAIN_SCREEN", image: XCUIScreen.main.screenshot().image, application: app) { result in
            print("Success - \(result)")
            screenshotExpectation.fulfill()
        } errorHandler: { error in
            print(error?.localizedDescription ?? "")
            screenshotExpectation.fulfill()
        }
        
        wait(for: [screenshotExpectation], timeout: 30)
        
        
        app.otherElements.buttons.element(matching: .button, identifier: "addListBtn").tap()
        
        let addListExpectation = self.expectation(description: "ADD_LIST screenshot")
        
        CrowdinSDK.captureOrUpdateScreenshot(name: "ADD_LIST", image: XCUIScreen.main.screenshot().image, application: app) { result in
            print("Success - \(result)")
            addListExpectation.fulfill()
        } errorHandler: { error in
            print(error?.localizedDescription ?? "")
            addListExpectation.fulfill()
        }
        
        wait(for: [addListExpectation], timeout: 30)
    }

}
