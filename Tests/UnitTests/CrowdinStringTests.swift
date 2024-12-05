//
//  StringsTest.swift
//  TestsTests
//
//  Created by Serhii Londar on 13.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class CrowdinStringTestsLocalization: XCTestCase {
    let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en"))
    
    override func tearDown() {
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testCrowdinSDKStringLocalizationForDefaultLanguage() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        CrowdinSDK.currentLocalization = nil
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            print("test_key".cw_localized)
            XCTAssert("test_key".cw_localized == "test_value [C]")
            XCTAssert("test_key_with_string_parameter".cw_localized(with: ["value"]) == "test value with parameter - value [C]")
            XCTAssert("test_key_with_int_parameter".cw_localized(with: [1]) == "test value with parameter - 1 [C]")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testCrowdinSDKStringLocalizationForDeLanguage() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        CrowdinSDK.currentLocalization = "de"
        
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            print("test_key".cw_localized)
            XCTAssert("test_key".cw_localized == "Testwert [C]")
            XCTAssert("test_key_with_string_parameter".cw_localized(with: ["value"]) == "Testwert mit Parameter - value [C]")
            XCTAssert("test_key_with_int_parameter".cw_localized(with: [1]) == "Testwert mit Parameter - 1 [C]")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testCrowdinSDKStringLocalizationForUkLanguage() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        CrowdinSDK.currentLocalization = "uk"
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            print("test_key".cw_localized)
            XCTAssert("test_key".cw_localized == "Тестове значення [C]")
            XCTAssert("test_key_with_string_parameter".cw_localized(with: ["value"]) == "значення тесту з параметром - value [C]")
            XCTAssert("test_key_with_int_parameter".cw_localized(with: [1]) == "значення тесту з параметром - 1 [C]")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testCrowdinSDKStringLocalizationForEnLanguage() {
        let expectation = XCTestExpectation(description: "Download handler is called")
        
        CrowdinSDK.currentLocalization = "en"
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            print("test_key".cw_localized)
            XCTAssert("test_key".cw_localized == "test_value [C]")
            XCTAssert("test_key_with_string_parameter".cw_localized(with: ["value"]) == "test value with parameter - value [C]")
            XCTAssert("test_key_with_int_parameter".cw_localized(with: [1]) == "test value with parameter - 1 [C]")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60.0)
    }
}

