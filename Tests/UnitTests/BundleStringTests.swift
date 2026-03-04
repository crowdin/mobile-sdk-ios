//
//  BundleStringTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 13.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class BundleStringTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() { }
    
    func testBundleStringLocalizationForDefaultLanguage() {
        XCTAssert("test_key".cw_localized == "test_value [B]")
        XCTAssert("test_key_with_string_parameter".cw_localized(with: ["value"]) == "test value with parameter - value [B]")
        XCTAssert("test_key_with_int_parameter".cw_localized(with: [1]) == "test value with parameter - 1 [B]")
    }
    
    func testPluralLocalizationWithKeyInBothFiles() {
        // Test for issue #347: When a key exists in both .strings and .stringsdict files,
        // plural forms should take precedence over the simple string.
        // This test validates the SDK swizzling path (LocalizationProvider) where the same key
        // exists in both strings and plurals dictionaries.
        
        let localization = "en"
        let key = "johns_pineapples_count"
        let simpleStringValue = "John has pineapples"
        
        let strings: [String: String] = [key: simpleStringValue]
        let plurals: [AnyHashable: Any] = [
            key: [
                "NSStringLocalizedFormatKey": "%#@pineapples@",
                "pineapples": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "zero": "John has no pineapples",
                    "one": "John has %d pineapple",
                    "other": "John has %d pineapples"
                ]
            ]
        ]
        
        let localStorage = LocalLocalizationStorage(localization: localization)
        localStorage.strings = strings
        localStorage.plurals = plurals
        localStorage.save()
        
        let remoteStorage = MockRemoteStorage()
        let provider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)
        
        Bundle.swizzle()
        Localization.current = Localization(provider: provider)
        defer {
            Bundle.unswizzle()
            Localization.current = nil
            provider.deintegrate()
        }
        
        // The provider should return the plural form, not the simple string
        let result = provider.localizedString(for: key)
        XCTAssertNotNil(result, "Plural key should resolve to a non-nil value")
        XCTAssertNotEqual(result, simpleStringValue, "Plural should take precedence over simple string")
        
        // Verify through Bundle.main which exercises the full swizzled path
        let format = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        let formattedOne = String.localizedStringWithFormat(format, 1)
        XCTAssertEqual(formattedOne, "John has 1 pineapple", "Singular plural form should work via swizzled path: '\(formattedOne)'")
        
        let formattedMany = String.localizedStringWithFormat(format, 5)
        XCTAssertEqual(formattedMany, "John has 5 pineapples", "Plural form should work via swizzled path: '\(formattedMany)'")
    }
}

