//
//  BundleSwizzleTests.swift
//  Tests
//
//  Created by Serhii Londar on 13/08/2024.
//  Copyright © 2024 Crowdin. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class BundleSwizzleTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Bundle.swizzle()
    }
    
    override func tearDown() {
        Bundle.unswizzle()
        super.tearDown()
    }
    
    func testRecursiveErrorDescriptionCrash() {
        let expectation = XCTestExpectation(description: "Error description does not crash")
        
        // This custom error's localizedDescription will be called,
        // which in turn will trigger the swizzled method.
        let error = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // Create a mock localization provider that will simulate the condition
        // that leads to the recursive call.
        let provider = MockLocalizationProvider(
            localization: "en",
            localStorage: MockLocalStorage(),
            remoteStorage: MockRemoteStorage()
        )
        let localization = Localization(provider: provider)
        Localization.current = localization
        
        // Accessing the localizedDescription should not cause a crash.
        // We are not asserting the result, just that this line doesn't crash.
        _ = error.localizedDescription
        
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

