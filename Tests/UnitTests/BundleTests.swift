//
//  BundleTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 19.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class BundleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppName() {
        XCTAssert(Bundle.main.appName == "Tests")
    }
    
    func testBundleId() {
        XCTAssert(Bundle.main.bundleId == "com.slon.Tests")
    }
    
    func testVersionNumber() {
        XCTAssert(Bundle.main.versionNumber == "1.0")
    }
    
    func testBuildNumber() {
        XCTAssert(Bundle.main.buildNumber == "1")
    }
    
    func testLaunchStoryboardName() {
        XCTAssert(Bundle.main.launchStoryboardName == "LaunchScreen")
    }
    
    func testDevelopmentRegion() {
        XCTAssert(Bundle.main.developmentRegion == "en")
    }
    
    func testCrowdinHash() {
        XCTAssert(Bundle.main.crowdinHash == "5290b1cfa1eb44bf2581e78106i")
    }
    
    func testCrowdinLocalizations() {
        let localizations = Bundle.main.cw_localizations
        XCTAssertNotNil(localizations)
        XCTAssert(localizations!.contains("en"))
        XCTAssert(localizations!.contains("de"))
        XCTAssert(localizations!.contains("uk"))
    }
    
    func testProjectKey() {
        let projectKey = Bundle.main.projectKey
        XCTAssertNil(projectKey)
    }
    
    func testCrowdinFilesNames() {
        let crowdinStringsFileNames = Bundle.main.crowdinFiles
        XCTAssertNotNil(crowdinStringsFileNames)
        XCTAssert(crowdinStringsFileNames!.contains("Localizable.strings"))
        XCTAssert(crowdinStringsFileNames!.contains("Main.strings"))
        XCTAssert(crowdinStringsFileNames!.contains("Localizable.stringsdict"))
    }
    
    func testCrowdinSourceLanguage() {
        XCTAssertNotNil(Bundle.main.crowdinSourceLanguage)
        XCTAssert(Bundle.main.crowdinSourceLanguage == "en")
    }
}
