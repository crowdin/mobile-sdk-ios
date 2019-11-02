import XCTest
@testable import CrowdinSDK

class CrowdinPathsParserTests: XCTestCase {
    var pathParser: CrowdinPathsParser!
    
    override func setUp() {
        self.pathParser = CrowdinPathsParser()
    }
    
    func testContainsLanguageCustomPath() {
        XCTAssert(self.pathParser.containsCustomPath("%language%/Localizable.strings"), "Should return true because %language% is custom path paramether.")
    }
    
    func testContainsLocaleCustomPath() {
        XCTAssert(self.pathParser.containsCustomPath("%locale%/Localizable.strings"), "Should return true because %locale% is custom path paramether.")
    }
    
    func testContainsLocaleWithUnderscoreCustomPath() {
        XCTAssert(self.pathParser.containsCustomPath("%locale_with_underscore%/Localizable.strings"), "Should return true because %locale_with_underscore% is custom path paramether.")
    }
    
    func testContainsOSXCodeCustomPath() {
        XCTAssert(self.pathParser.containsCustomPath("%osx_code%/Localizable.strings"), "Should return true because %osx_code% is custom path paramether.")
    }
    
    func testContainsOSXLocaleCustomPath() {
        XCTAssert(self.pathParser.containsCustomPath("%osx_locale%/Localizable.strings"), "Should return true because %osx_locale% is custom path paramether.")
    }
    
    func testContainsWrongCustomPath() {
        XCTAssertFalse(self.pathParser.containsCustomPath("%wrong_path%/Localizable.strings"), "Should return false because %wrong_path% is not custom path paramether.")
    }
    
    // mark - Locale
    
    func testParseLocaleCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en") == "en/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "de") == "de/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en-US") == "en-US/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en_US") == "en-US/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForZhLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "zh") == "zh/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "zh_Hant") == "zh-Hant/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "zh_Hans") == "zh-Hans/Localizable.strings", "")
    }
    
    // mark - Language
    
    func testParseLanguageCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "en") == "English/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "de") == "German/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForUkLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "uk") == "Ukrainian/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "en-US") == "English/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "en_US") == "English/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForZhLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "zh") == "Chinese/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "zh_Hant") == "Chinese/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "zh_Hans") == "Chinese/Localizable.strings", "")
    }
    
    // mark - Locale With Underscore

    func testParseLocaleWithUnderscoreCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en") == "en/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "de") == "de/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en-US") == "en_US/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en_US") == "en_US/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForZhLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "zh") == "zh/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "zh_Hant") == "zh_Hant/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "zh_Hans") == "zh_Hans/Localizable.strings", "")
    }
}
