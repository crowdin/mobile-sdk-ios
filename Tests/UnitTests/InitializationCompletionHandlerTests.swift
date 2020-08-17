//
//  InitializationCompletionHandlerTests.swift
//  Tests
//
//  Created by Serhii Londar on 18.08.2020.
//  Copyright © 2020 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class InitializationCompletionHandlerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testInitializationCompletionHandlerCalled() {
        let expectation = XCTestExpectation(description: "Initialization completion handler is called")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "wrong_hash",
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(enterprise: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            XCTAssert(true, "Initialization completion handler called")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60.0)
    }

}
