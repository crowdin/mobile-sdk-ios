//
//  HandlersTests.swift
//  Tests
//
//  Created by Serhii Londar on 12.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class SDKModeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
                                                          files: ["test.strings", "error.strings", "test.stringsdict"],
                                                          localizations: ["en", "de", "uk"],
                                                          sourceLanguage: "en")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
                                                        .with(enterprise: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig)
        CrowdinSDK.enableSDKLocalization(true, localization: nil)
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CrowdinSDK.enableSDKLocalization(true, localization: nil)
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testInitialMode() {
        XCTAssert(CrowdinSDK.mode == .autoSDK, "Auto sdk mode is enabled by default")
        XCTAssert(CrowdinSDK.currentLocalization == "en", "Should be en as it is preffered localization")
    }
    
    
    func testInitialChangeModeToCustomSDK() {
        XCTAssert(CrowdinSDK.mode == .autoSDK, "Auto sdk mode is enabled by default")
        
        CrowdinSDK.mode = .customSDK
        CrowdinSDK.currentLocalization = "de"
        
        XCTAssert(CrowdinSDK.mode == .customSDK, "Mode and localization changed so current mode should be customSDK")
        XCTAssert(CrowdinSDK.currentLocalization == "de", "Should be saved to de")
    }
    
    
    func testInitialChangeModeToAutoBundle() {
        XCTAssert(CrowdinSDK.mode == .autoSDK, "Auto sdk mode is enabled by default")
        
        CrowdinSDK.mode = .autoBundle
        CrowdinSDK.currentLocalization = "de"
        
        XCTAssert(CrowdinSDK.mode == .autoBundle, "Mode and localization changed so current mode should be customSDK")
        XCTAssert(CrowdinSDK.currentLocalization == "en", "Should be en as it is preffered localization")
    }
    
    
    func testInitialChangeModeToCustomBundle() {
        XCTAssert(CrowdinSDK.mode == .autoSDK, "Auto sdk mode is enabled by default")
        
        CrowdinSDK.mode = .customBundle
        CrowdinSDK.currentLocalization = "de"
        
        XCTAssert(CrowdinSDK.mode == .customBundle, "Mode and localization changed so current mode should be customBundle")
        XCTAssert(CrowdinSDK.currentLocalization == "de", "Should be en as it is preffered localization")
    }

}
