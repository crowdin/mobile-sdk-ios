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

    // MARK: - isSafeFormatString (CWE-134)

    func testIsSafeFormatStringRejectsMoreSpecifiersThanArguments() {
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
        let translation = "Score: %@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [5]))
    }

    func testIsSafeFormatStringRejectsObjectSpecifierForBoolArgument() {
        let translation = "Enabled: %@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [true]))
    }

    func testIsSafeFormatStringRejectsObjectSpecifierForCGFloatArgument() {
        let translation = "Progress: %@"
        let value: CGFloat = 0.5
        XCTAssertFalse(translation.isSafeFormatString(arguments: [value]))
    }

    func testIsSafeFormatStringRejectsNumericSpecifierForStringArgument() {
        // "%x" on a String leaks its bridged object pointer.
        let translation = "Score: %x"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testCwSafeFormatFallsBackWhenTranslationIsUnsafe() {
        let maliciousTranslation = "Hallo %@ %@ %@ %@ %@"
        let result = String.cw_safeFormat(maliciousTranslation, arguments: ["Alice"], fallbackKey: "unsafe_format_fallback_key")

        // Missing bundle resource returns the key itself, confirming fallback.
        XCTAssertEqual(result, "unsafe_format_fallback_key")
    }

    func testCwSafeFormatUsesTranslationWhenSafe() {
        let translation = "Hello %@"
        let result = String.cw_safeFormat(translation, arguments: ["Alice"], fallbackKey: "unused_fallback_key")

        XCTAssertEqual(result, "Hello Alice")
    }

    // MARK: - Escaped-percent bypass (CWE-134)
    // "%%%d" is literal "%" + real "%d" and still consumes an argument.

    func testIsSafeFormatStringRejectsEscapedPercentFollowedByExcessSpecifiers() {
        let translation = "%%%d %%%d %%%d %%%d %%%d %%%d"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
        XCTAssertFalse(translation.isSafeFormatString(arguments: []))
    }

    func testIsSafeFormatStringRejectsEscapedPercentFollowedByObjectSpecifier() {
        let translation = "Score: %%%@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [5]))
    }

    func testIsSafeFormatStringRejectsRepeatedEscapedObjectBeyondArguments() {
        let translation = "%%%@ %%%@"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringAcceptsLiteralPercentBeforeRealSpecifier() {
        let translation = "100%% done: %@"
        XCTAssert(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringAcceptsPureLiteralPercentEscapes() {
        let translation = "Progress: 100%%"
        XCTAssert(translation.isSafeFormatString(arguments: []))
        XCTAssert(translation.isSafeFormatString(arguments: ["unused"]))
    }

    // MARK: - %s / %p mismatch (CWE-134)
    // %s on non-C-strings segfaults in CoreFoundation; %p on objects leaks addresses.

    func testIsSafeFormatStringRejectsCStringSpecifierForStringArgument() {
        let translation = "id=%s"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringRejectsCStringSpecifierForIntArgument() {
        let translation = "id=%s"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [5]))
    }

    func testIsSafeFormatStringAcceptsCStringSpecifierForCStringPointerArgument() {
        let translation = "id=%s"
        "Alice".withCString { cString in
            XCTAssert(translation.isSafeFormatString(arguments: [cString]))
        }
    }

    func testIsSafeFormatStringRejectsVoidPointerSpecifierForStringArgument() {
        let translation = "ptr=%p"
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringAcceptsVoidPointerSpecifierForIntArgument() {
        // "%p" on Int prints a scalar value, not an object address.
        let translation = "ptr=%p"
        XCTAssert(translation.isSafeFormatString(arguments: [5]))
    }

    // MARK: - Positional specifiers and parser bounds (CWE-134)

    func testIsSafeFormatStringHandlesPositionalSpecifiers() {
        let translation = "%2$@ has %1$d messages"
        XCTAssert(translation.isSafeFormatString(arguments: [3, "Alice"]))
        XCTAssertFalse(translation.isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringRejectsOversizedPositionalSpecifier() {
        // Reject huge positions without allocating a padding array.
        let translation = "%999999999$d"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [1]))
    }

    func testIsSafeFormatStringRejectsIntOverflowPositionalSpecifier() {
        let translation = "%99999999999999999999$d"
        XCTAssertFalse(translation.isSafeFormatString(arguments: [1]))
    }

    // MARK: - %L length modifier (CWE-134)

    func testIsSafeFormatStringCountsLongDoubleSpecifier() {
        // "%Lf" consumes a Double argument in String(format:).
        let translation = "x%Lf"
        XCTAssert(translation.isSafeFormatString(arguments: [2.5]))
        XCTAssertFalse(translation.isSafeFormatString(arguments: []))
    }

    // MARK: - Escaped-percent reverse lookup

    func testFindMatchSupportsLiteralPercentBeforeSpecifier() {
        // Reverse lookup must match the safety parser on "100%% done: %@".
        XCTAssert(String.findMatch(for: "100%% done: %@", with: "100% done: Alice"))
        XCTAssertFalse(String.findMatch(for: "100%% done: %@", with: "something else"))
    }

    func testFindValuesSupportsLiteralPercentBeforeSpecifier() {
        let result = String.findValues(for: "100% done: Alice", with: "100%% done: %@")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first as? String, "Alice")
    }

    func testSplitByWithEmptyRanges() {
        // Regression: empty ranges used to trap on `0...(-1)`.
        let result = ("Awesome string" as NSString).splitBy(ranges: [])
        XCTAssert(result.isEmpty)
    }

    func testIsFormatedWithLiteralPercentEscapes() {
        XCTAssert("%%%d".isFormated)
        XCTAssertFalse("100%%".isFormated)
    }

    // MARK: - CoreFoundation grammar edge cases (CWE-134)

    func testIsSafeFormatStringRejectsAlternateFormFlagBeyondArguments() {
        XCTAssertFalse("%#x %#x %#x %#x %#x %#x".isSafeFormatString(arguments: [3]))
    }

    func testIsSafeFormatStringRejectsSpaceFlagBeyondArguments() {
        XCTAssertFalse("% x % x % x".isSafeFormatString(arguments: [3]))
    }

    func testIsSafeFormatStringRejectsCombinedFlagsBeyondArguments() {
        XCTAssertFalse("%-+x %-+x %-+x".isSafeFormatString(arguments: [3]))
    }

    func testIsSafeFormatStringRejectsLengthModifiedCharacterAndStringBeyondArguments() {
        XCTAssertFalse("%lc%lc%lc".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("%ls%ls".isSafeFormatString(arguments: [3]))
    }

    func testIsSafeFormatStringRejectsStarWidthAndPrecision() {
        XCTAssertFalse("%*d".isSafeFormatString(arguments: [3, 4]))
        XCTAssertFalse("%.*f".isSafeFormatString(arguments: [3, 4.0]))
        XCTAssertFalse("%1$*2$d".isSafeFormatString(arguments: [3, 4]))
    }

    func testIsSafeFormatStringRejectsPercentN() {
        // %n writes to a pointer argument without printing, shifting later slots.
        XCTAssertFalse("%n%n%n%d".isSafeFormatString(arguments: [1, 2, 3]))
    }

    func testIsSafeFormatStringRejectsFlagsFollowedByPercent() {
        XCTAssertFalse("%5%d".isSafeFormatString(arguments: [1]))
        XCTAssertFalse("% %d".isSafeFormatString(arguments: [1]))
    }

    func testIsSafeFormatStringRejectsOversizedWidthAndPrecision() {
        XCTAssertFalse("%99999999d".isSafeFormatString(arguments: [1]))
        XCTAssertFalse("%.99999999f".isSafeFormatString(arguments: [1.0]))
    }

    func testIsSafeFormatStringRejectsMixedSequentialAndPositionalSpecifiers() {
        XCTAssertFalse("%1$d %d".isSafeFormatString(arguments: [1, 2]))
    }

    func testIsSafeFormatStringRejectsOnePositionReadAsTwoTypes() {
        XCTAssertFalse("%1$d %1$@".isSafeFormatString(arguments: [1]))
    }

    func testIsSafeFormatStringAcceptsFlagsWidthAndPrecision() {
        let translation = "%-10@|%5.2f|%+d|%#x|%lld|%05d|%1.3lf"
        XCTAssert(translation.isSafeFormatString(arguments: ["a", 1.5, 2, 3, 4, 5, 6.0]))
    }

    func testIsSafeFormatStringTreatsUnknownConversionAsLiteral() {
        // CoreFoundation prints unknown conversions like "%y" literally.
        XCTAssert("100%y done".isSafeFormatString(arguments: []))
        XCTAssert("Save 5%".isSafeFormatString(arguments: []))
    }

    func testIsSafeFormatStringCountsSpaceFlagConversionInPlainText() {
        // "100% done" parses as "% d" + "one" (space flag + d), consuming an Int.
        XCTAssertFalse("100% done".isSafeFormatString(arguments: []))
        XCTAssert("100% done".isSafeFormatString(arguments: [5]))
    }

    func testIsSafeFormatStringAcceptsReferenceSlot() {
        XCTAssert("%#@n@".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("%#@n@ %#@m@".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("%#@n@".isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringRejectsPercentInsideReferenceName() {
        // Foundation rejects "%#@a%p...@" as a reference and parses inner "%p"s.
        XCTAssertFalse("%#@a%p%p%p@".isSafeFormatString(arguments: ["Alice"]))
        XCTAssertFalse("%#@a%x%x%x@".isSafeFormatString(arguments: [1]))
        XCTAssertFalse("%1$#@a%p@".isSafeFormatString(arguments: [1]))
    }

    func testIsSafeFormatStringRejectsUppercasePointerAndWideStringConversions() {
        // CoreFoundation crashes on `%P` and `%S`; they are not aliases of `%p`/`%s`.
        XCTAssertFalse("Items: %P".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("Items: %S".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("Items: %lP".isSafeFormatString(arguments: [3]))
        XCTAssertFalse("Items: %1$S".isSafeFormatString(arguments: ["Alice"]))
    }

    func testIsSafeFormatStringAcceptsUppercaseConversionsCoreFoundationSupports() {
        XCTAssert("%X %E %G %A %F".isSafeFormatString(arguments: [1, 1.0, 1.0, 1.0, 1.0]))
        XCTAssert("%D %O %U %C".isSafeFormatString(arguments: [1, 2, 3, 65]))
    }

    func testIsSafeFormatStringOnlyAcceptsCoreFoundationUppercaseConversions() {
        // Every A-Z either matches the CoreFoundation-supported set or is rejected / printed literally.
        let consumingScalar: Set<Character> = ["A", "C", "D", "E", "F", "G", "O", "U", "X"]
        // `%P`/`%S` crash CoreFoundation; `%N` is rejected alongside `%n`.
        let rejected: Set<Character> = ["N", "P", "S"]
        for scalar in UnicodeScalar("A").value...UnicodeScalar("Z").value {
            let letter = Character(UnicodeScalar(scalar)!)
            let format = "Items: %\(letter)"
            if rejected.contains(letter) {
                XCTAssertFalse(format.isSafeFormatString(arguments: [3]), format)
            } else if consumingScalar.contains(letter) {
                XCTAssert(format.isSafeFormatString(arguments: [3]), format)
                XCTAssertFalse(format.isSafeFormatString(arguments: []), format)
            } else {
                // Unknown conversions are printed literally and consume nothing.
                XCTAssert(format.isSafeFormatString(arguments: []), format)
            }
        }
    }

    func testIsSafeFormatStringTreatsNonIdentifierReferenceNameAsObjectConversion() {
        // CoreFoundation parses `%#@<non-identifier>@` as a `#`-flagged `%@`, which crashes on scalars.
        let names = [" ", ".", "$", "=", "\"", "-", "#", "'", "ab.", "abc!", "x+", "a b", "a-b", "é", "\u{00A0}", "\u{200B}", "\t"]
        for name in names {
            let format = "Items: %#@\(name)@"
            XCTAssertFalse(format.isSafeFormatString(arguments: [3]), format.debugDescription)
            XCTAssert(format.isSafeFormatString(arguments: ["Alice"]), format.debugDescription)
        }
    }

    func testIsSafeFormatStringAcceptsIdentifierReferenceNames() {
        for name in ["a", "name", "a_b", "A1", "_", "9"] {
            XCTAssert("Items: %#@\(name)@".isSafeFormatString(arguments: [3]), name)
        }
    }

    func testIsSafeFormatStringCountsThreeOrMoreLengthModifiersAndOutOfOrderModifiers() {
        // CoreFoundation accepts 3+ length modifiers and arbitrary modifier order.
        XCTAssertFalse("%lllp".isSafeFormatString(arguments: []))
        XCTAssertFalse("%hhhp".isSafeFormatString(arguments: []))
        XCTAssertFalse("%lllx".isSafeFormatString(arguments: []))
        XCTAssertFalse("%l+p".isSafeFormatString(arguments: []))
        XCTAssertFalse("%5-p".isSafeFormatString(arguments: []))
        XCTAssertFalse("%l5p".isSafeFormatString(arguments: []))
        XCTAssertFalse("%1.2.3f".isSafeFormatString(arguments: []))
        XCTAssert("%llld".isSafeFormatString(arguments: [42]))
    }

    func testIsSafeFormatStringRejectsPositionalDollarAfterModifiers() {
        XCTAssertFalse("%+1$d".isSafeFormatString(arguments: [42]))
        XCTAssertFalse("%1$2$d".isSafeFormatString(arguments: [1, 2]))
        XCTAssertFalse("%l1$d".isSafeFormatString(arguments: [42]))
        XCTAssertFalse("%0$d".isSafeFormatString(arguments: [42]))
    }

    func testIsSafeFormatStringRejectsNonScalarObjectsForNumericSpecifiers() {
        // NSObject subclasses (NSURL, NSNumber) would leak pointer addresses under numeric specifiers.
        let url = NSURL(string: "https://example.com")!
        XCTAssertFalse("%llx".isSafeFormatString(arguments: [url]))
        XCTAssertFalse("%d".isSafeFormatString(arguments: [NSNumber(value: 5)]))
        XCTAssertFalse("%f".isSafeFormatString(arguments: [NSObject()]))
    }

    func testIsFormatedHandlesEmojiBeforeSpecifier() {
        XCTAssert("🎉 %@".isFormated)
        XCTAssert(String.findMatch(for: "🎉 %@", with: "🎉 Alice"))
    }

    // MARK: - Plural (stringsdict) variants (CWE-134)

    private func pluralEntry(format: String = "%#@n@", valueType: String = "d", variants: [String: String]) -> [AnyHashable: Any] {
        var variable: [String: Any] = ["NSStringFormatSpecTypeKey": "NSStringPluralRuleType", "NSStringFormatValueTypeKey": valueType]
        variants.forEach { variable[$0.key] = $0.value }
        return ["NSStringLocalizedFormatKey": format, "n": variable]
    }

    func testPluralsValidatorAcceptsOrdinaryEntry() {
        XCTAssert(PluralsFormatValidator.isSafe(entry: pluralEntry(variants: ["one": "%d item", "other": "%d items"])))
    }

    func testPluralsValidatorAcceptsXcstringsStylePositionalEntry() {
        let entry = pluralEntry(format: "%1$@ has %2$#@n@", valueType: "lld", variants: ["one": "%2$lld item", "other": "%2$lld items"])
        XCTAssert(PluralsFormatValidator.isSafe(entry: entry))
    }

    func testPluralsValidatorAcceptsNonPositionalVariantInMultiArgEntry() {
        let entry = pluralEntry(format: "%1$@ has %2$#@n@", valueType: "d", variants: ["one": "%d item", "other": "%d items"])
        XCTAssert(PluralsFormatValidator.isSafe(entry: entry))
    }

    func testPluralsValidatorRejectsVariantTargetingNonNumericSlot() {
        let entry = pluralEntry(format: "%1$@ has %2$#@n@", valueType: "d", variants: ["one": "%1$d item", "other": "%1$d items"])
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: entry))
    }

    func testPluralsValidatorRejectsVariantWithExtraSpecifiers() {
        let entry = pluralEntry(variants: ["one": "%d item", "other": "%d items %x %x %x %x"])
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: entry))
    }

    func testPluralsValidatorRejectsVariantReadingBeyondFormatKeyArguments() {
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: pluralEntry(variants: ["other": "%9$d items"])))
    }

    func testPluralsValidatorRejectsNonNumericVariantSpecifier() {
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: pluralEntry(variants: ["other": "%@ items"])))
    }

    func testPluralsValidatorRejectsNonNumericValueType() {
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: pluralEntry(valueType: "@", variants: ["other": "items"])))
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: pluralEntry(valueType: "s", variants: ["other": "items"])))
    }

    func testPluralsValidatorRejectsEntryWithoutFormatKey() {
        XCTAssertFalse(PluralsFormatValidator.isSafe(entry: ["n": ["other": "%d"]]))
    }

    func testPluralsValidatorSanitizedKeepsOnlySafeEntries() {
        let plurals: [AnyHashable: Any] = [
            "good": pluralEntry(variants: ["other": "%d items"]),
            "bad": pluralEntry(variants: ["other": "%d items %x %x"])
        ]
        let sanitized = PluralsFormatValidator.sanitized(plurals)
        XCTAssertEqual(Set(sanitized.keys), ["good"])
    }
}
