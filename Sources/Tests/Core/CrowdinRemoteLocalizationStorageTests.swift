//
//  CrowdinRemoteLocalizationStorageTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Created by Serhii Londar on 15.03.2022.
//

import XCTest
@testable import CrowdinSDK

class CrowdinRemoteLocalizationStorageTests: XCTestCase {
    let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en")
    // swiftlint:disable implicitly_unwrapped_optional
    var remoteLocalizationStorage: CrowdinRemoteLocalizationStorage!
    
    override func setUp() {
        CrowdinSDK.deintegrate()
    }
    
    override func tearDown() {
        remoteLocalizationStorage.deintegrate()
        remoteLocalizationStorage = nil
    }
    
    func testInitialization() {
        remoteLocalizationStorage = CrowdinRemoteLocalizationStorage(localization: "en", config: crowdinProviderConfig)
        
        XCTAssertTrue(remoteLocalizationStorage.localization == "en")
        XCTAssertTrue(remoteLocalizationStorage.hashString == "5290b1cfa1eb44bf2581e78106i")
    }
    
    func testPreparation() {
        let preparationExpectation = XCTestExpectation(description: "Provider preperation")
        
        remoteLocalizationStorage = CrowdinRemoteLocalizationStorage(localization: "en", config: crowdinProviderConfig)
        remoteLocalizationStorage.manifestManager.clear()
        remoteLocalizationStorage.prepare {
            preparationExpectation.fulfill()
        }
        
        wait(for: [preparationExpectation], timeout: 120.0)
        
        XCTAssertTrue(remoteLocalizationStorage.localizations.count == 3, "Should contain 3 localizations, contains \(remoteLocalizationStorage.localizations.count) instead")
        XCTAssertTrue(remoteLocalizationStorage.localizations.contains("en"))
        XCTAssertTrue(remoteLocalizationStorage.localizations.contains("de"))
        XCTAssertTrue(remoteLocalizationStorage.localizations.contains("uk"))
    }
    
    func testFetchDataForEn() {
        let dataExpectation = XCTestExpectation(description: "Data fetch")
        let preparationExpectation = XCTestExpectation(description: "Provider preperation")
        
        remoteLocalizationStorage = CrowdinRemoteLocalizationStorage(localization: "en", config: crowdinProviderConfig)
        
        remoteLocalizationStorage.prepare {
            preparationExpectation.fulfill()
        }
        
        wait(for: [preparationExpectation], timeout: 60.0)
        
        remoteLocalizationStorage.fetchData { localizations, localization, strings, plurals in
            XCTAssertTrue(localization == "en")
            XCTAssertTrue(localizations?.count == 3)
            
            XCTAssertNotNil(strings)
            XCTAssertTrue(strings?.count == 5)
            
            XCTAssertNotNil(plurals)
            XCTAssertTrue(plurals?.count == 2)
            
            dataExpectation.fulfill()
        } errorHandler: { error in
            XCTFail(error.localizedDescription)
            dataExpectation.fulfill()
        }

        wait(for: [dataExpectation], timeout: 60.0)
    }
    
    func testChangeLanguageAndFetchDataForEn() {
        let dataExpectation = XCTestExpectation(description: "Data fetch")
        let preparationExpectation = XCTestExpectation(description: "Provider preperation")
        
        remoteLocalizationStorage = CrowdinRemoteLocalizationStorage(localization: "en", config: crowdinProviderConfig)
        
        remoteLocalizationStorage.prepare {
            preparationExpectation.fulfill()
        }
        
        wait(for: [preparationExpectation], timeout: 60.0)
        
        remoteLocalizationStorage.localization = "de"
        remoteLocalizationStorage.fetchData { localizations, localization, strings, plurals in
            print("localizations - \(localizations)")
            XCTAssertTrue(localization == "de")
            XCTAssertTrue(localizations?.count == 3)
            
            print("localizations - \(strings)")
            XCTAssertNotNil(strings)
            XCTAssertTrue(strings?.count == 5)
            
            print("localizations - \(plurals)")
            XCTAssertNotNil(plurals)
            XCTAssertTrue(plurals?.count == 2)
            
            dataExpectation.fulfill()
        } errorHandler: { error in
            XCTFail(error.localizedDescription)
            dataExpectation.fulfill()
        }

        wait(for: [dataExpectation], timeout: 60.0)
    }
}
