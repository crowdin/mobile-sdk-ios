//
//  TestsTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 09.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class TestsTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
														  stringsFileNames: ["Localizable.strings"],
														  pluralsFileNames: ["Localizable.stringsdict"],
														  localizations: ["en", "de", "uk"],
														  sourceLanguage: "en")
//		let loginConfig = CrowdinLoginConfig(clientId: "XjNxVvoJh6XMf8NGnwuG",
//											 clientSecret: "Dw5TxCKvKQQRcPyAWEkTCZlxRGmcja6AFZNSld6U",
//											 scope: "project.screenshot",
//											 redirectURI: "crowdintest://",
//											 organizationName: "serhiy")
		let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
//														.with(loginConfig: loginConfig)
		CrowdinSDK.startWithConfig(crowdinSDKConfig)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testSupportedLocalizations() {
		XCTAssert(CrowdinSDK.inSDKLocalizations.count == 3)
	}
	
	func testInBundleLocalizations() {
		XCTAssert(CrowdinSDK.inBundleLocalizations.count == 2, "Contains Base & English localizations.")
	}
	
	
}
