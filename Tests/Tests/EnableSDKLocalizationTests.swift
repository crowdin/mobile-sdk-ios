//
//  EnableSDKLocalizationTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 13.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class EnableSDKLocalizationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i",
                                                          stringsFileNames: ["Localizable.strings", "Main.strings"],
                                                          pluralsFileNames: ["Localizable.stringsdict"],
                                                          localizations: ["en", "de", "uk"],
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
        
        CrowdinSDK.startWithConfig(crowdinSDKConfig)
    }
    
    
    override func tearDown() {
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.enableSDKLocalization(true, localization: nil)
        CrowdinSDK.deintegrate()
    }
    
    func testAutoSDKModeEnabled() {
        CrowdinSDK.enableSDKLocalization(true, localization: nil)
        
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(CrowdinSDK.mode == .autoSDK, "Shouuld enable autoSDK mode and redownload localization")
            XCTAssert(CrowdinSDK.currentLocalization == "en", "Shouuld auto detect current localization as en")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testManualSDKModeEnabled() {
        CrowdinSDK.enableSDKLocalization(true, localization: "de")
        
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(CrowdinSDK.mode == .customSDK, "Shouuld enable customSDK mode and redownload localization")
            XCTAssert(CrowdinSDK.currentLocalization == "de", "Shouuld set current localization to de")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    
    func testAutoBundleModeEnabled() {
        CrowdinSDK.enableSDKLocalization(false, localization: nil)
        
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(CrowdinSDK.mode == .autoBundle, "Shouuld enable autoBundle mode and redownload localization")
            XCTAssert(CrowdinSDK.currentLocalization == "en", "Shouuld auto detect current localization as en")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testManualBundleModeEnabled() {
        CrowdinSDK.enableSDKLocalization(false, localization: "de")
        
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(CrowdinSDK.mode == .customBundle, "Shouuld enable customBundle mode and redownload localization")
            XCTAssert(CrowdinSDK.currentLocalization == "de", "Shouuld set current localization to de")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}

