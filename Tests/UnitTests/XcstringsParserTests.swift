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
    
    func testParseXcstringsWithSanitizedKeyCollision() {
        // Verify that keys with different special characters (e.g., "test%key" and "test@key")
        // do NOT collide thanks to unicode-based encoding. Each special character maps to a
        // unique escape sequence (_u25 for %, _u40 for @).
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
        
        let sanitizedPercentKey = XcstringsParser.sanitizeFormatVariable("test%key")
        let sanitizedAtKey = XcstringsParser.sanitizeFormatVariable("test@key")
        
        // Unicode encoding ensures different special characters produce different sanitized keys
        XCTAssertNotEqual(sanitizedPercentKey, sanitizedAtKey, "Different special characters should produce different sanitized keys")
        XCTAssertEqual(sanitizedPercentKey, "test_u25key")
        XCTAssertEqual(sanitizedAtKey, "test_u40key")
        
        if let strings = result.strings {
            // Both entries are preserved - no collision occurs
            XCTAssertEqual(strings.count, 2, "Both entries should be preserved (no collision)")
            XCTAssertEqual(strings["test%key"], "Value with percent")
            XCTAssertEqual(strings["test@key"], "Value with at sign")
        }
    }
    
    func testParseXcstringsWithSubstitutionsSpecialCharacterKeys() {
        // Verify that sanitization is applied to substitution key names,
        // not only to the plural variations path.
        let jsonString = """
        {
          "sourceLanguage": "en",
          "version": "1.0",
          "strings": {
            "greeting": {
              "localizations": {
                "en": {
                  "stringUnit": {
                    "state": "translated",
                    "value": "You have %#@count%items@"
                  },
                  "substitutions": {
                    "count%items": {
                      "argNum": 1,
                      "formatSpecifier": "lld",
                      "variations": {
                        "plural": {
                          "one": {
                            "stringUnit": {
                              "state": "translated",
                              "value": "one item"
                            }
                          },
                          "other": {
                            "stringUnit": {
                              "state": "translated",
                              "value": "%arg items"
                            }
                          }
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
        
        let result = XcstringsParser.parse(data: data, localization: "en")
        
        XCTAssertNil(result.error, "Parsing should not produce an error")
        XCTAssertNotNil(result.plurals, "Plurals should be parsed")
        
        if let plurals = result.plurals {
            XCTAssertNotNil(plurals["greeting"], "Plural entry should exist for key 'greeting'")
            
            if let pluralDict = plurals["greeting"] as? [String: Any] {
                // The format key should use the sanitized substitution key name
                let sanitizedKey = XcstringsParser.sanitizeFormatVariable("count%items")
                let formatKey = pluralDict["NSStringLocalizedFormatKey"] as? String
                XCTAssertEqual(formatKey, "%#@\(sanitizedKey)@", "Format key should reference sanitized substitution key")
                
                // The sanitized substitution key dictionary should exist
                let variableDict = pluralDict[sanitizedKey] as? [String: Any]
                XCTAssertNotNil(variableDict, "Sanitized substitution key should exist in plural dict")
                
                // The original unsanitized key should NOT be present
                XCTAssertNil(pluralDict["count%items"] as? [String: Any], "Original unsanitized key should not exist")
                
                if let variableDict = variableDict {
                    XCTAssertEqual(variableDict["one"] as? String, "one item")
                    XCTAssertEqual(variableDict["other"] as? String, "%1$lld items")
                    XCTAssertEqual(variableDict["NSStringFormatSpecTypeKey"] as? String, "NSStringPluralRuleType")
                    XCTAssertEqual(variableDict["NSStringFormatValueTypeKey"] as? String, "lld")
                }
            }
        }
    }
    
    func testFormatsFunction() {
        // Basic format specifier
        XCTAssertEqual(XcstringsParser.formats(from: "Valid for %lld days"), ["lld"])
        
        // Multiple format specifiers
        XCTAssertEqual(XcstringsParser.formats(from: "%d items in %lld days"), ["d", "lld"])
        
        // Format specifier at end of string (trailing specifier fix)
        XCTAssertEqual(XcstringsParser.formats(from: "Value: %d"), ["d"])
        XCTAssertEqual(XcstringsParser.formats(from: "Count: %lld"), ["lld"])
        
        // @ specifier at end of string
        XCTAssertEqual(XcstringsParser.formats(from: "Hello %@"), ["@"])
        
        // No specifiers
        XCTAssertEqual(XcstringsParser.formats(from: "No specifiers here"), [])
        
        // Empty string
        XCTAssertEqual(XcstringsParser.formats(from: ""), [])
        
        // Single character specifier at end
        XCTAssertEqual(XcstringsParser.formats(from: "%u"), ["u"])
    }

    // MARK: - %arg replacement tests

    /// Verifies that `%arg` (xcstrings design-time placeholder) is replaced
    /// with the actual format specifier so the generated stringsdict matches
    /// what Xcode produces when compiling the xcstrings file.
    func testDictForReplacesArgPlaceholder() {
        // Build a substitution that mirrors the "tasks_completed_in_days" pattern.
        let tasksForms: [String: StringUnitWrapper] = [
            "one":   StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg task completed in %#@days@")),
            "other": StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg tasks completed in %#@days@")),
            "zero":  StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "No tasks completed in %#@days@"))
        ]
        let daysForms: [String: StringUnitWrapper] = [
            "one":   StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg day")),
            "other": StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg days")),
            "zero":  StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "today"))
        ]

        let tasksSubstitution = Substitution(
            argNum: nil,
            formatSpecifier: "lld",
            variations: Variations(plural: tasksForms)
        )
        let daysSubstitution = Substitution(
            argNum: nil,
            formatSpecifier: "lld",
            variations: Variations(plural: daysForms)
        )
        let allSubstitutions = ["tasks": tasksSubstitution, "days": daysSubstitution]

        let tasksDict = XcstringsParser.dictFor(substitution: tasksSubstitution, with: allSubstitutions)
        let daysDict = XcstringsParser.dictFor(substitution: daysSubstitution, with: allSubstitutions)

        // %arg in tasks forms must be replaced with %lld (the formatSpecifier)
        XCTAssertEqual(tasksDict?["one"]   as? String, "%lld task completed in %#@days@")
        XCTAssertEqual(tasksDict?["other"] as? String, "%lld tasks completed in %#@days@")
        XCTAssertEqual(tasksDict?["zero"]  as? String, "No tasks completed in %#@days@")

        // %arg in days forms must be replaced with %lld
        XCTAssertEqual(daysDict?["one"]   as? String, "%lld day")
        XCTAssertEqual(daysDict?["other"] as? String, "%lld days")
        XCTAssertEqual(daysDict?["zero"]  as? String, "today")
    }

    /// Verifies that when `argNum` is set, `%arg` is replaced with a positional
    /// specifier (e.g. `%1$lld`) instead of a plain `%lld`.
    func testDictForReplacesArgPlaceholderWithArgNum() {
        let forms: [String: StringUnitWrapper] = [
            "one":   StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg item")),
            "other": StringUnitWrapper(stringUnit: StringUnit(state: "translated", value: "%arg items"))
        ]
        let substitution = Substitution(
            argNum: 2,
            formatSpecifier: "lld",
            variations: Variations(plural: forms)
        )

        let dict = XcstringsParser.dictFor(substitution: substitution, with: [:])

        XCTAssertEqual(dict?["one"]   as? String, "%2$lld item")
        XCTAssertEqual(dict?["other"] as? String, "%2$lld items")
    }

    /// End-to-end: parse a `tasks_completed_in_days`-style xcstrings entry and
    /// verify that the resulting plural dict contains `%lld` (not `%arg`) in its
    /// plural form strings.
    func testParseXcstringsWithArgPlaceholderReplacement() {
        let jsonString = """
        {
          "sourceLanguage": "en",
          "version": "1.0",
          "strings": {
            "tasks_completed_in_days": {
              "extractionState": "migrated",
              "localizations": {
                "en": {
                  "stringUnit": {
                    "state": "translated",
                    "value": "%#@tasks@"
                  },
                  "substitutions": {
                    "days": {
                      "formatSpecifier": "lld",
                      "variations": {
                        "plural": {
                          "one":   { "stringUnit": { "state": "translated", "value": "%arg day" } },
                          "other": { "stringUnit": { "state": "translated", "value": "%arg days" } },
                          "zero":  { "stringUnit": { "state": "translated", "value": "today" } }
                        }
                      }
                    },
                    "tasks": {
                      "formatSpecifier": "lld",
                      "variations": {
                        "plural": {
                          "one":   { "stringUnit": { "state": "translated", "value": "%arg task completed in %#@days@" } },
                          "other": { "stringUnit": { "state": "translated", "value": "%arg tasks completed in %#@days@" } },
                          "zero":  { "stringUnit": { "state": "translated", "value": "No tasks completed in %#@days@" } }
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
            XCTFail("Failed to encode JSON"); return
        }

        let result = XcstringsParser.parse(data: data, localization: "en")
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.plurals)

        guard let entry = result.plurals?["tasks_completed_in_days"] as? [String: Any] else {
            XCTFail("tasks_completed_in_days plural entry missing"); return
        }

        XCTAssertEqual(entry["NSStringLocalizedFormatKey"] as? String, "%#@tasks@")

        guard let tasksDict = entry["tasks"] as? [String: Any] else {
            XCTFail("tasks sub-dict missing"); return
        }
        // %arg must have been replaced with %lld — no %arg should remain
        XCTAssertEqual(tasksDict["one"]   as? String, "%lld task completed in %#@days@")
        XCTAssertEqual(tasksDict["other"] as? String, "%lld tasks completed in %#@days@")
        XCTAssertFalse((tasksDict["one"]   as? String ?? "").contains("%arg"), "%%arg must not remain in 'one' form")
        XCTAssertFalse((tasksDict["other"] as? String ?? "").contains("%arg"), "%%arg must not remain in 'other' form")

        guard let daysDict = entry["days"] as? [String: Any] else {
            XCTFail("days sub-dict missing"); return
        }
        XCTAssertEqual(daysDict["one"]   as? String, "%lld day")
        XCTAssertEqual(daysDict["other"] as? String, "%lld days")
        XCTAssertFalse((daysDict["one"]   as? String ?? "").contains("%arg"), "%%arg must not remain in days 'one' form")
        XCTAssertFalse((daysDict["other"] as? String ?? "").contains("%arg"), "%%arg must not remain in days 'other' form")
    }
}
