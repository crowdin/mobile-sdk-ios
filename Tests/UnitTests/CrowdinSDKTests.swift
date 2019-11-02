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
		super.setUp()
		let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
														  files: ["Localizable.strings", "Localizable.stringsdict"],
														  localizations: ["en", "de", "uk"],
														  sourceLanguage: "en")
		let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
		CrowdinSDK.startWithConfig(crowdinSDKConfig)
        CrowdinSDK.enableSDKLocalization(true, localization: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }

	func testSupportedLocalizations() {
		XCTAssert(CrowdinSDK.inSDKLocalizations.count == 3)
	}
	
	func testInBundleLocalizations() {
		XCTAssert(CrowdinSDK.inBundleLocalizations.count == 4, "Contains Base, English, German and Ukrainian localizations.")
	}
	
	func testCurrentLocalization() {
		XCTAssert(CrowdinSDK.currentLocalization == "en")
	}
	
	func testMode() {
		XCTAssert(CrowdinSDK.mode == .autoSDK)
	}
    
    func testConfig() {
        XCTAssertNotNil(CrowdinSDK.config, "Confish should not be a nil")
    }
}
