//
//  TestsTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 09.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class CrowdinSDKTests: XCTestCase {
    override func setUp() {
        CrowdinSDK.deintegrate()
		super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }

	func testSupportedLocalizations() {
        let expectation = XCTestExpectation()
        
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i",
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
        CrowdinSDK.currentLocalization = nil
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60.0)
        
		XCTAssert(CrowdinSDK.inSDKLocalizations.count == 3)
	}
	
	func testInBundleLocalizations() {
        let expectation = XCTestExpectation()
        
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i",
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
        CrowdinSDK.currentLocalization = nil
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60.0)
        
		XCTAssert(CrowdinSDK.inBundleLocalizations.count == 3, "Contains English, German and Ukrainian localizations.")
	}
	
	func testCurrentLocalization() {
        let expectation = XCTestExpectation()
        
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i",
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
        CrowdinSDK.currentLocalization = nil
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60.0)
        
		XCTAssert(CrowdinSDK.currentLocalization == "en")
	}
    
    func testConfig() {
        XCTAssertNotNil(CrowdinSDK.config, "Confish should not be a nil")
    }
}
