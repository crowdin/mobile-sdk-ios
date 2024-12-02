//
//  CrowdinRemoteLocalizationStorageTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Created by Serhii Londar on 15.03.2022.
//

import XCTest
@testable import CrowdinSDK

class RealLocalizationProviderTests: XCTestCase {
    let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en")
    var localizationProvider: LocalizationProvider!
    
    var providerExpectedStringsKeys = [
        "nqC-BB-OHN.text",
        "test_key",
        "test_key_with_int_parameter",
        "test_key_with_string_parameter",
        "test_key_with_two_parameters"
    ]
    var providerPluralsExpectedKeys = [
        "johns_pineapples_count",
        "lu_completed_runs"
    ]
    
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
        
        XCTAssertNotNil(localizationProvider)
        XCTAssertTrue(localizationProvider.localization == localization)
        XCTAssertTrue(localizationProvider.localizations == [])
        XCTAssertTrue(localizationProvider.strings.isEmpty)
        XCTAssertTrue(localizationProvider.plurals.isEmpty)
        XCTAssertNotNil(localizationProvider.pluralsBundle)
        XCTAssertNotNil(localizationProvider.pluralsFolder)
        XCTAssertNotNil(localizationProvider.stringsDataSource)
        XCTAssertNotNil(localizationProvider.pluralsDataSource)
    }
    
    func testFetchDataBeforeRemoteStoragePrepered() {
        let localization = "en"
        let localStorage = LocalLocalizationStorage(localization: localization)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
        let expectation = expectation(description: "Localization refreshed")
        
        localizationProvider.refreshLocalization { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testFetchDataAfterRemoteStoragePrepared(with localization: String) {
        let localStorage = LocalLocalizationStorage(localization: localization)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
        let expectation = expectation(description: "Localization refreshed")
        
        remoteStorage.prepare {
            XCTAssertFalse(self.localizationProvider.localizations.isEmpty)
            XCTAssertTrue(self.localizationProvider.localizations.contains(localization))
            
            self.localizationProvider.refreshLocalization { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        
        XCTAssertFalse(localizationProvider.strings.isEmpty)
        XCTAssertTrue(localizationProvider.strings.count == providerExpectedStringsKeys.count)
        let stringsKeys = localizationProvider.strings.keys
        providerExpectedStringsKeys.forEach({
            XCTAssertTrue(stringsKeys.contains($0), "\(stringsKeys) should contains - \($0)")
        })
        
        
        XCTAssertFalse(localizationProvider.plurals.isEmpty)
        XCTAssertTrue(localizationProvider.plurals.count == providerPluralsExpectedKeys.count)
        providerPluralsExpectedKeys.forEach({
            XCTAssertTrue(localizationProvider.plurals.keys.contains($0))
        })
    }
    
    func testFetchDataAfterRemoteStoragePreparedForEnLocalization() {
        testFetchDataAfterRemoteStoragePrepared(with: "en")
    }
    
    func testFetchDataAfterRemoteStoragePreparedForDeLocalization() {
        testFetchDataAfterRemoteStoragePrepared(with: "de")
    }
    
    func testFetchDataAfterRemoteStoragePreparedForUkLocalization() {
        testFetchDataAfterRemoteStoragePrepared(with: "uk")
    }
    
    
    var providerExpectedEnStrings = [
        "nqC-BB-OHN.text": "List of strings:",
        "test_key": "test_value [C]",
        "test_key_with_int_parameter": "test value with parameter - %lu [C]",
        "test_key_with_string_parameter": "test value with parameter - %@ [C]",
        "test_key_with_two_parameters": "test value with parameter - %@, and parameter - %@ [C]"
    ]
    
    var providerExpectedUkStrings = [
        "nqC-BB-OHN.text": "Список рядків:",
        "test_key": "Тестове значення [C]",
        "test_key_with_int_parameter": "значення тесту з параметром - %lu [C]",
        "test_key_with_string_parameter": "значення тесту з параметром - %@ [C]",
        "test_key_with_two_parameters": "значення тесту з параметром - %@, а параметром - %@ [C]"
    ]
    
    var providerExpectedDeStrings = [
        "nqC-BB-OHN.text": "Liste der Saiten:",
        "test_key": "Testwert [C]",
        "test_key_with_int_parameter": "Testwert mit Parameter - %lu [C]",
        "test_key_with_string_parameter": "Testwert mit Parameter - %@ [C]",
        "test_key_with_two_parameters": "Testwert mit Parameter - %@und Parameter - %@ [C]"
    ]
    
    func testStringsLocalization(for localization: String) {
        let expectedStringsMap = [
            "en": providerExpectedEnStrings,
            "de": providerExpectedDeStrings,
            "uk": providerExpectedUkStrings
        ]
        
        testFetchDataAfterRemoteStoragePrepared(with: localization)
        
        guard let strings = expectedStringsMap[localization] else {
            XCTFail("No expected strings for \(localization)")
            return
        }
        
        providerExpectedStringsKeys.forEach {
            XCTAssertNotNil(localizationProvider.localizedString(for: $0))
            XCTAssertNotNil(strings[$0])
            
            XCTAssert(localizationProvider.localizedString(for: $0) == strings[$0], "\(String(describing: localizationProvider.localizedString(for: $0))) should be equal to \(String(describing: strings[$0]))")
        }
    }
    
    func testStringsLocalizationForEn() {
        testStringsLocalization(for: "en")
    }
    
    func testStringsLocalizationForDe() {
        testStringsLocalization(for: "de")
    }
    
    func testStringsLocalizationForUk() {
        testStringsLocalization(for: "uk")
    }
    
    func testPluralsForEnLocalization() {
        testFetchDataAfterRemoteStoragePrepared(with: "en")
        
        Bundle.swizzle()
        Localization.current = Localization(provider: localizationProvider)
         
        let plural1 = localizationProvider.localizedString(for:"johns_pineapples_count")
        XCTAssertNotNil(plural1)
        XCTAssertTrue(plural1 == "%#@v1_pineapples_count@")
        print(String(format: plural1!, 0))
        XCTAssertTrue(String(format: plural1!, 0) == "John has 0 pineapples [CW]", String(format: plural1!, 0))
        XCTAssertTrue(String(format: plural1!, 1) == "John has one pineapple [CW]", String(format: plural1!, 1))
        XCTAssertTrue(String(format: plural1!, 10) == "John has 10 pineapples [CW]", String(format: plural1!, 10))
        
        
        let plural2 = localizationProvider.localizedString(for:"lu_completed_runs")
        XCTAssertNotNil(plural2)
        XCTAssertTrue(plural2 == "%1$#@lu_completed_runs@")
        
        XCTAssertTrue(String(format: plural2!, 0, 0) == "0 of 0 runs completed [CW]", String(format: plural2!, 0, 0))
        XCTAssertTrue(String(format: plural2!, 10, 20) == "10 of 20 runs completed [CW]", String(format: plural2!, 10, 20))
        
        Bundle.unswizzle()
        Localization.current = nil
    }
    
}
