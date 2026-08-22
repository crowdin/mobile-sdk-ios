//
//  StringParamTests.swift
//  CrowdinSDK-Unit-CrowdinSDK_Tests
//
//  Created by Serhii Londar on 10/4/19.
//

import XCTest
@testable import CrowdinSDK

class StringsTests: XCTestCase {
    func testIsFormatedWithFormatedString() {
        let string = "test string with parameter - %@"
        XCTAssert(string.isFormated == true, "String has format parameter - %@")
	}
    
    func testIsFormatedWithNonFormatedString() {
        let string = "test string without parameters"
        XCTAssert(string.isFormated == false, "String has no any parameters")
    }
    
    func testFindMatchWithFormatedString() {
        let formatedString = "test string with parameter - %@"
        let string = "test string with parameter - value"
        
        let result = String.findMatch(for: formatedString, with: string)
        
        XCTAssert(result == true, "Expected because value is parameter for formattedString")
    }
    
    func testFindMatchWithNonFormatedString() {
        let formatedString = "test string"
        let string = "test string with parameter - value"
        
        let result = String.findMatch(for: formatedString, with: string)
        
        XCTAssert(result == false, "Expected because formattedString is not formatted")
    }
    
    func testNSStringSplitByRanges() {
        let string: NSString = "Test string"
        let result = string.splitBy(ranges: [NSRange(location: 4, length: 1)])
        
        XCTAssert(result.count == 2, "Expect 2 strings")
        XCTAssert(result[0] == "Test", "First string is \"Test\"")
        XCTAssert(result[1] == "string", "First string is \"string\"")
    }
    
    func testNSStringSplitByRanges2() {
        let string: NSString = "test string with parameter - value"
        let result = string.splitBy(ranges: [NSRange(location: 0, length: 29)])
        
        XCTAssert(result.count == 1, "Expect 1 string")
        XCTAssert(result[0] == "value", "Expect value string")
    }
    
    func testFindValuesForString() {
        let formatedString = "test string with parameter - %@"
        let string = "test string with parameter - value"
        
        let result = String.findValues(for: string, with: formatedString)
        
        XCTAssertNotNil(result, "Expect non nil result")
        if let result = result {
            XCTAssert(result.count == 1, "Expect 1 string")
            // swiftlint:disable force_cast
            XCTAssert(result[0] as! String == "value", "Expect 1 string")
        }
    }
    
    func testFindValuesForUInt() {
        let formatedString = "Int value = %llu"
        let string = "Int value = 23"

        let result = String.findValues(for: string, with: formatedString)

        XCTAssertNotNil(result, "Expect non nil result")
        if let result = result {
            XCTAssert(result.count == 1, "Expect 1 result")
            XCTAssertNotNil(result[0] as? UInt, "Expect 1 UInt")
            // swiftlint:disable force_cast
            XCTAssert(result[0] as! UInt == 23, "Expect 23")
        }
    }

    // MARK: - isSafeFormatString (CWE-134: externally controlled format string).

    func testIsSafeFormatStringRejectsMoreSpecifiersThanArguments() {
        // Mirrors the reported PoC: a downloaded translation with more specifiers
        // than the app supplied arguments would read past the argument list.
        let translation = "Hallo %@ %x %x %x %x %x %x"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringRejectsRepeatedObjectSpecifiersBeyondArguments() {
        let translation = "Hallo %@ %@ %@ %@ %@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringAcceptsMatchingCountAndTypes() {
        let translation = "Hello %@, you have %d messages"
        XCTAssert(translation.isSafeFormatString(arguments: ["Alice", 5]))
    }

    func testIsSafeFormatStringAcceptsFewerSpecifiersThanArguments() {
        let translation = "Hello %@"
        XCTAssert(translation.isSafeFormatString(arguments: ["Alice", 5]), "Unused trailing arguments are not a safety issue")
    }

    func testIsSafeFormatStringRejectsObjectSpecifierForScalarArgument() {
        // "%@" on a plain Int would dereference the Int's bit pattern as a pointer.
        let translation = "Score: %@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [5]))
    }

    func testIsSafeFormatStringRejectsNumericSpecifierForStringArgument() {
        // "%x" on a String would print its bridged pointer as a number.
        let translation = "Score: %x"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testCwSafeFormatFallsBackWhenTranslationIsUnsafe() {
        let maliciousTranslation = "Hallo %@ %@ %@ %@ %@"
        let result = String.cw_safeFormat(maliciousTranslation, arguments: ["Alice"], fallbackKey: "unsafe_format_fallback_key")

        // No bundled resource exists for this key in the test target, so
        // Bundle.bundledLocalizedString returns the key itself - proving the
        // unsafe translation was not handed to String(format:).
        XCTAssertEqual(result, "unsafe_format_fallback_key")
    }

    func testCwSafeFormatUsesTranslationWhenSafe() {
        let translation = "Hello %@"
        let result = String.cw_safeFormat(translation, arguments: ["Alice"], fallbackKey: "unused_fallback_key")

        XCTAssertEqual(result, "Hello Alice")
    }
}
