//
//  XcstringsParserTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 22.02.2026.
//

import XCTest
@testable import CrowdinSDK

class XcstringsParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSanitizeFormatVariable() {
        // Test encoding % characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("creditsValid%lld"), "creditsValid_u25lld")
        
        // Test encoding @ characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test@key"), "test_u40key")
        
        // Test with both % and @
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test%lld@extra"), "test_u25lld_u40extra")
        
        // Test with normal key (no special characters)
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("normalKey"), "normalKey")
        
        // Test with key starting with number
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("1test"), "var_1test")
        
        // Edge case: key composed entirely of special characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("%%@@"), "_u25_u25_u40_u40")
        
        // Edge case: key with whitespace
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test key"), "test_u20key")
        
        // Edge case: key with whitespace and special characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test key % value"), "test_u20key_u20_u25_u20value")
        
        // Edge case: all percent signs
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("%%%%"), "_u25_u25_u25_u25")
        
        // Edge case: multiple consecutive special characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test%%key"), "test_u25_u25key")
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test@@key"), "test_u40_u40key")
        
        // Edge case: empty string
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable(""), "var_")
        
        // Uniqueness: different special characters produce different results
        XCTAssertNotEqual(
            XcstringsParser.sanitizeFormatVariable("test%key"),
            XcstringsParser.sanitizeFormatVariable("test@key")
        )
    }

    func testParseXcstringsWithPluralsContainingFormatSpecifiers() {
        // Create a sample .xcstrings structure similar to the user's example
        let jsonString = """
        {
          "sourceLanguage": "en",
          "version": "1.0",
          "strings": {
            "creditsValid%lld": {
              "extractionState": "manual",
              "localizations": {
                "en": {
                  "variations": {
                    "plural": {
                      "one": {
                        "stringUnit": {
                          "state": "translated",
                          "value": "Valid for %lld day"
                        }
                      },
                      "other": {
                        "stringUnit": {
                          "state": "translated",
                          "value": "Valid for %lld days"
                        }
                      }
                    }
                  }
                },
                "de": {
                  "variations": {
                    "plural": {
                      "one": {
                        "stringUnit": {
                          "state": "translated",
                          "value": "Gültig für %lld Tag"
                        }
                      },
                      "other": {
                        "stringUnit": {
                          "state": "translated",
                          "value": "Gültig für %lld Tage"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // Parse for English
        let resultEN = XcstringsParser.parse(data: data, localization: "en")
        
        XCTAssertNil(resultEN.error, "Parsing should not produce an error")
        XCTAssertNotNil(resultEN.plurals, "Plurals should be parsed")
        
        if let plurals = resultEN.plurals {
            // Check that the key is present in the plurals dictionary
            XCTAssertNotNil(plurals["creditsValid%lld"], "Plural entry should exist for key 'creditsValid%lld'")
            
            if let pluralDict = plurals["creditsValid%lld"] as? [String: Any] {
                // Check NSStringLocalizedFormatKey is present and uses sanitized variable name
                let formatKey = pluralDict["NSStringLocalizedFormatKey"] as? String
                XCTAssertNotNil(formatKey, "NSStringLocalizedFormatKey should exist")
                
                // The format key should use the sanitized variable name (creditsValid_u25lld)
                XCTAssertEqual(formatKey, "%#@creditsValid_u25lld@", "Format key should use sanitized variable name")
                
                // Check that the sanitized variable name dictionary exists
                let variableDict = pluralDict["creditsValid_u25lld"] as? [String: Any]
                XCTAssertNotNil(variableDict, "Variable dictionary with sanitized name should exist")
                
                if let variableDict = variableDict {
                    // Check plural variations
                    XCTAssertEqual(variableDict["one"] as? String, "Valid for %lld day")
                    XCTAssertEqual(variableDict["other"] as? String, "Valid for %lld days")
                    XCTAssertEqual(variableDict["NSStringFormatSpecTypeKey"] as? String, "NSStringPluralRuleType")
                    XCTAssertEqual(variableDict["NSStringFormatValueTypeKey"] as? String, "lld")
                }
            }
        }
        
        // Parse for German
        let resultDE = XcstringsParser.parse(data: data, localization: "de")
        
        XCTAssertNil(resultDE.error, "Parsing should not produce an error")
        XCTAssertNotNil(resultDE.plurals, "Plurals should be parsed")
        
        if let plurals = resultDE.plurals {
            if let pluralDict = plurals["creditsValid%lld"] as? [String: Any] {
                if let variableDict = pluralDict["creditsValid_u25lld"] as? [String: Any] {
                    // Check German plural variations
                    XCTAssertEqual(variableDict["one"] as? String, "Gültig für %lld Tag")
                    XCTAssertEqual(variableDict["other"] as? String, "Gültig für %lld Tage")
                }
            }
        }
    }
    
    func testParseXcstringsWithSimpleStrings() {
        let jsonString = """
        {
          "sourceLanguage": "en",
          "version": "1.0",
          "strings": {
            "hello": {
              "localizations": {
                "en": {
                  "stringUnit": {
                    "state": "translated",
                    "value": "Hello"
                  }
                }
              }
            }
          }
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        let result = XcstringsParser.parse(data: data, localization: "en")
        
        XCTAssertNil(result.error, "Parsing should not produce an error")
        XCTAssertNotNil(result.strings, "Strings should be parsed")
        
        if let strings = result.strings {
            XCTAssertEqual(strings["hello"], "Hello")
        }
    }
    
    func testParseXcstringsWithSanitizedKeyUniqueness() {
        // Verify that keys with different special characters do NOT collide
        // when using unicode-based encoding.
        let jsonString = """
        {
          "sourceLanguage": "en",
          "version": "1.0",
          "strings": {
            "test%key": {
              "localizations": {
                "en": {
                  "stringUnit": {
                    "state": "translated",
                    "value": "Value with percent"
                  }
                }
              }
            },
            "test@key": {
              "localizations": {
                "en": {
                  "stringUnit": {
                    "state": "translated",
                    "value": "Value with at sign"
                  }
                }
              }
            }
          }
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        let result = XcstringsParser.parse(data: data, localization: "en")
        
        XCTAssertNil(result.error, "Parsing should not produce an error")
        XCTAssertNotNil(result.strings, "Strings should be parsed")
        
        // With unicode encoding, "test%key" -> "test_u25key" and "test@key" -> "test_u40key"
        // so both entries are preserved without collision.
        if let strings = result.strings {
            XCTAssertEqual(strings.count, 2, "Both entries should be preserved (no collision)")
            XCTAssertEqual(strings["test%key"], "Value with percent")
            XCTAssertEqual(strings["test@key"], "Value with at sign")
        }
    }
}
