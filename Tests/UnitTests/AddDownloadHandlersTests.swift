//
//  HandlersTests.swift
//  Tests
//
//  Created by Serhii Londar on 12.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class AddDownloadHandlersTests: IntegrationTestCase {
    let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en"))
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testAddDownloadHandler() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        _ = CrowdinSDK.addDownloadHandler {
            XCTAssert(true, "Download handler called")
            expectation.fulfill()
        }
        
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {})
        
        wait(for: [expectation], timeout: 60.0)
    }

}
