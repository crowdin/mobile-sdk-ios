//
//  CrowdinRemoteLocalizationStorageTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Created by Serhii Londar on 15.03.2022.
//

import XCTest
@testable import CrowdinSDK

class RealLocalizationProviderTests: IntegrationTestCase {
    let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en")
    // swiftlint:disable implicitly_unwrapped_optional
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
        // Ensure global state from other tests doesn't affect these tests
        Bundle.unswizzle()
        Localization.current = nil
        CrowdinSDK.currentLocalization = nil
        ManifestManager.clear()
    }
    
    override func tearDown() {
        localizationProvider?.deintegrate()
        localizationProvider = nil
        ManifestManager.clear()
        super.tearDown()
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
    
    func testFetchDataAfterRemoteStoragePrepared(with localization: String, completion: @escaping (() -> Void)) {
        let localStorage = LocalLocalizationStorage(localization: localization)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        remoteStorage.manifestManager.clear()
        localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
        
        remoteStorage.prepare {
            self.localizationProvider.refreshLocalization { error in
                XCTAssertNil(error)
                
                XCTAssertFalse(self.localizationProvider.strings.isEmpty)
                XCTAssertTrue(self.localizationProvider.strings.count == self.providerExpectedStringsKeys.count)
                let stringsKeys = self.localizationProvider.strings.keys
                self.providerExpectedStringsKeys.forEach({
                    XCTAssertTrue(stringsKeys.contains($0), "\(stringsKeys) should contains - \($0)")
                })
                
                XCTAssertFalse(self.localizationProvider.plurals.isEmpty)
                XCTAssertTrue(self.localizationProvider.plurals.count == self.providerPluralsExpectedKeys.count)
                self.providerPluralsExpectedKeys.forEach({
                    XCTAssertTrue(self.localizationProvider.plurals.keys.contains($0))
                })
                
                completion()
            }
        }
    }
    
    func testFetchDataAfterRemoteStoragePreparedForEnLocalization() {
        let expectation = expectation(description: "Localization refreshed")
        testFetchDataAfterRemoteStoragePrepared(with: "en") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testFetchDataAfterRemoteStoragePreparedForDeLocalization() {
        let expectation = expectation(description: "Localization refreshed")
        testFetchDataAfterRemoteStoragePrepared(with: "de") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testFetchDataAfterRemoteStoragePreparedForUkLocalization() {
        let expectation = expectation(description: "Localization refreshed")
        testFetchDataAfterRemoteStoragePrepared(with: "uk") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
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
    
    func testStringsLocalization(for localization: String, completion: @escaping (() -> Void)) {
        let expectedStringsMap = [
            "en": providerExpectedEnStrings,
            "de": providerExpectedDeStrings,
            "uk": providerExpectedUkStrings
        ]
        
        testFetchDataAfterRemoteStoragePrepared(with: localization) {
            guard let strings = expectedStringsMap[localization] else {
                XCTFail("No expected strings for \(localization)")
                completion()
                return
            }
            
            self.providerExpectedStringsKeys.forEach {
                XCTAssertNotNil(self.localizationProvider.localizedString(for: $0))
                XCTAssertNotNil(strings[$0])
                
                // swiftlint:disable line_length
                XCTAssert(self.localizationProvider.localizedString(for: $0) == strings[$0], "\(String(describing: self.localizationProvider.localizedString(for: $0))) should be equal to \(String(describing: strings[$0]))")
            }
            completion()
        }
    }
    
    func testStringsLocalizationForEn() {
        let expectation = expectation(description: "Localization refreshed")
        testStringsLocalization(for: "en") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testStringsLocalizationForDe() {
        let expectation = expectation(description: "Localization refreshed")
        testStringsLocalization(for: "de") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testStringsLocalizationForUk() {
        let expectation = expectation(description: "Localization refreshed")
        testStringsLocalization(for: "uk") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testPluralsForEnLocalization() {
        let expectation = expectation(description: "Localization refreshed")
        testFetchDataAfterRemoteStoragePrepared(with: "en") {
            
            Bundle.swizzle()
            Localization.current = Localization(provider: self.localizationProvider)
            
            let plural1 = self.localizationProvider.localizedString(for: "johns_pineapples_count")
            XCTAssertNotNil(plural1)
            XCTAssertTrue(plural1 == "%#@v1_pineapples_count@")
            // swiftlint:disable force_unwrapping
            print(String(format: plural1!, 0))
            XCTAssertTrue(String(format: plural1!, 0) == "John has 0 pineapples [CW]", String(format: plural1!, 0))
            XCTAssertTrue(String(format: plural1!, 1) == "John has one pineapple [CW]", String(format: plural1!, 1))
            XCTAssertTrue(String(format: plural1!, 10) == "John has 10 pineapples [CW]", String(format: plural1!, 10))
            
            let plural2 = self.localizationProvider.localizedString(for: "lu_completed_runs")
            XCTAssertNotNil(plural2)
            XCTAssertTrue(plural2 == "%1$#@lu_completed_runs@")
            
            XCTAssertTrue(String(format: plural2!, 0, 0) == "0 of 0 runs completed [CW]", String(format: plural2!, 0, 0))
            XCTAssertTrue(String(format: plural2!, 10, 20) == "10 of 20 runs completed [CW]", String(format: plural2!, 10, 20))
            
            Bundle.unswizzle()
            Localization.current = nil
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}
