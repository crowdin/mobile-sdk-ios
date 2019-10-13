//
//  CrowdinTesterTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 13.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class CrowdinTesterTests: XCTestCase {
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
    }
    
    func testDownloadedLocalizations() {
        let expectation = XCTestExpectation(description: "Error handler is called")
        let tester = CrowdinTester(localization: "en")
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(tester.inSDKPluralsKeys.count == 2, "Downloaded localization contains 2 plural keys")
            XCTAssert(tester.inSDKStringsKeys.count == 5, "Downloaded localization contains 5 string keys")
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)

        XCTAssert(tester.localization == "en", "Localization should be en")
    }
    
    
    func testChangeAndDownloadLocalizations() {
        CrowdinSDK.mode = .customSDK
        CrowdinSDK.currentLocalization = "de"
        
        let expectation = XCTestExpectation(description: "Error handler is called")
        let tester = CrowdinTester(localization: "de")
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(tester.inSDKPluralsKeys.count == 2, "Downloaded localization contains 2 plural keys")
            XCTAssert(tester.inSDKStringsKeys.count == 5, "Downloaded localization contains 5 string keys")
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)

        XCTAssert(tester.localization == "de", "Localization should be de")
    }
}
