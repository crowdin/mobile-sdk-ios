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
        // Test removing % characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("creditsValid%lld"), "creditsValid_lld")
        
        // Test removing @ characters
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test@key"), "test_key")
        
        // Test with both % and @
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("test%lld@extra"), "test_lld_extra")
        
        // Test with normal key (no special characters)
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("normalKey"), "normalKey")
        
        // Test with key starting with number
        XCTAssertEqual(XcstringsParser.sanitizeFormatVariable("1test"), "var_1test")
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
                
                // The format key should use the sanitized variable name (creditsValid_lld)
                XCTAssertEqual(formatKey, "%#@creditsValid_lld@", "Format key should use sanitized variable name")
                
                // Check that the sanitized variable name dictionary exists
                let variableDict = pluralDict["creditsValid_lld"] as? [String: Any]
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
                if let variableDict = pluralDict["creditsValid_lld"] as? [String: Any] {
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
}
