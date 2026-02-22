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
        // plural forms should take precedence over the simple string
        
        // The key "johns_pineapples_count" exists in both:
        // - Localizable.strings: "John has pineapples" (simple fallback string)
        // - Localizable.stringsdict: proper plural definitions (zero/one/other)
        
        // Format for zero (should use plural from stringsdict, not simple string)
        let formatZero = NSLocalizedString("johns_pineapples_count", comment: "")
        let stringZero = String.localizedStringWithFormat(formatZero, 0)
        XCTAssert(stringZero == "John has no pineapples", "Zero plural form should work: '\(stringZero)'")
        
        // Format for one (should use plural from stringsdict)
        let formatOne = NSLocalizedString("johns_pineapples_count", comment: "")
        let stringOne = String.localizedStringWithFormat(formatOne, 1)
        XCTAssert(stringOne == "John has 1 pineapple", "Singular plural form should work: '\(stringOne)'")
        
        // Format for multiple (should use plural from stringsdict)
        let formatMany = NSLocalizedString("johns_pineapples_count", comment: "")
        let stringMany = String.localizedStringWithFormat(formatMany, 5)
        XCTAssert(stringMany == "John has 5 pineapples", "Plural form should work: '\(stringMany)'")
    }
}

