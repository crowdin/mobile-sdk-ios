//
//  HandlersTests.swift
//  Tests
//
//  Created by Serhii Londar on 12.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class AddDownloadHandlersTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
                                                          stringsFileNames: ["Localizable.strings"],
                                                          pluralsFileNames: ["Localizable.stringsdict"],
                                                          localizations: ["en", "de", "uk"],
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(enterprise: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig)
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.removeAllDownloadHandlers()
    }
    
    func testAddDownloadHandler() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        let hendlerId = CrowdinSDK.addDownloadHandler {
            XCTAssert(true, "Download handler called")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        CrowdinSDK.removeErrorHandler(hendlerId)
    }

}
