//
//  AppleRemindersUITestsLaunchTests.swift
//  AppleRemindersUITests
//
//  Created by Serhii Londar on 26.11.2024.
//  Copyright © 2024 Josh R. All rights reserved.
//

import XCTest

final class AppleRemindersUITestsLaunchTests: XCTestCase {
//
//    override class var runsForEachTargetApplicationUIConfiguration: Bool {
//        true
//    }
//
//    override func setUpWithError() throws {
//        continueAfterFailure = false
//    }
//
//    @MainActor
//    func testLaunch() throws {
//        let app = XCUIApplication()
//        app.launch()
//
//        // Insert steps here to perform after app launch but before taking a screenshot,
//        // such as logging into a test account or navigating somewhere in the app
//
//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)
//    }
//    
//    
    
    
    @MainActor
    func testScreenshots() throws {
        
        
        let app = XCUIApplication()
        app.launch()
        app.tables.containing(.other, identifier:"My Lists[L]").element.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Cancel[L]"]/*[[".buttons[\"Cancel[L]\"].staticTexts[\"Cancel[L]\"]",".staticTexts[\"Cancel[L]\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        
    }
}
