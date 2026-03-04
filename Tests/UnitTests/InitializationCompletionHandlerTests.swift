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
    override func tearDown() {
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testInitializationCompletionHandlerCalled() {
        let expectation = XCTestExpectation(description: "Initialization completion handler is called")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "wrong_hash",
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
        CrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {
            XCTAssert(true, "Initialization completion handler called")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 60.0)
    }

}

private class TrackingMockLocalizationProvider: MockLocalizationProvider {
    var setLocalizationCalls: [String] = []

    override func setLocalization(_ localization: String, completion: @escaping ((Error?) -> Void)) {
        setLocalizationCalls.append(localization)
        super.setLocalization(localization, completion: completion)
    }
}

class SetCurrentLocalizationCompletionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Localization.current = nil
        CrowdinSDK.currentLocalization = nil
    }

    override func tearDown() {
        Localization.current = nil
        CrowdinSDK.currentLocalization = nil
        super.tearDown()
    }

    func testSetCurrentLocalizationWithCompletionUpdatesProvider() {
        let provider = TrackingMockLocalizationProvider(
            localization: "en",
            localStorage: MockLocalStorage(),
            remoteStorage: MockRemoteStorage()
        )
        Localization.current = Localization(provider: provider)

        let completionExpectation = expectation(description: "Localization completion called")
        CrowdinSDK.setCurrentLocalization("de") { error in
            XCTAssertNil(error)
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 1.0)

        XCTAssertEqual(provider.setLocalizationCalls, ["de"])
        XCTAssertEqual(provider.localization, "de")
        XCTAssertEqual(CrowdinSDK.currentLocalization, "de")
    }

    func testSetCurrentLocalizationWithCompletionWithoutInitializedProviderCallsCompletion() {
        let completionExpectation = expectation(description: "Localization completion called")
        CrowdinSDK.setCurrentLocalization("de") { error in
            XCTAssertNil(error)
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 1.0)

        XCTAssertEqual(CrowdinSDK.currentLocalization, "de")
    }
}
