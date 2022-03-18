//
//  CrowdinRemoteLocalizationStorageTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Created by Serhii Londar on 15.03.2022.
//

import XCTest
@testable import CrowdinSDK

class LocalizationProviderTests: XCTestCase {
    let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en")
    var localizationProvider: LocalizationProvider!
    
    override func setUp() {

    }
    
    override func tearDown() {
        localizationProvider.deintegrate()
    }
    
    func testInitialization() {
        let localization = "en"
        let localStorage = LocalLocalizationStorage(localization: localization)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
    }
}
