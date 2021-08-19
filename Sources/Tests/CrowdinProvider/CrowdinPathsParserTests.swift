import XCTest
@testable import CrowdinSDK

class CrowdinPathsParserTests: XCTestCase {
    var pathParser = CrowdinPathsParser.shared
    
    override func setUp() {
        if CrowdinSupportedLanguages.shared.loaded == false {
            CrowdinSupportedLanguages.shared.downloadSupportedLanguagesSync()
        }
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
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en") == "en-US/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "de") == "de-DE/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en-US") == "en-US/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en_US") == "en-US/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForsZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "zh_Hant") == "zh-TW/Localizable.strings", "")
    }
    
    func testParseLocaleCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "zh_Hans") == "zh-CN/Localizable.strings", "")
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
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "en-US") == "English, United States/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "en_US") == "English, United States/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "zh_Hant") == "Chinese Traditional/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%language%/Localizable.strings", localization: "zh_Hans") == "Chinese Simplified/Localizable.strings", "")
    }
    
    // mark - Locale With Underscore

    func testParseLocaleWithUnderscoreCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en") == "en_US/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "de") == "de_DE/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en-US") == "en_US/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "en_US") == "en_US/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "zh_Hant") == "zh_TW/Localizable.strings", "")
    }
    
    func testParseLocaleWithUnderscoreCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%locale_with_underscore%/Localizable.strings", localization: "zh_Hans") == "zh_CN/Localizable.strings", "")
    }
    
    // mark - osx code

    func testParseOsxCodeCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "en") == "en.lproj/Localizable.strings", "")
    }
    
    func testParseOsxCodeCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "de") == "de.lproj/Localizable.strings", "")
    }
    
    func testParseOsxCodeCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "en-US") == "en-US.lproj/Localizable.strings", "")
    }
    
    func testParseOsxCodeCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "en_US") == "en-US.lproj/Localizable.strings", "")
    }
    
    func testParseOsxCodeCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "zh-Hant") == "zh-Hant.lproj/Localizable.strings", "")
    }
    
    func testParseOsxCodeCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%osx_code%/Localizable.strings", localization: "zh-Hans") == "zh-Hans.lproj/Localizable.strings", "")
    }
    
    // mark - osx locale

    func testParseOsxLocaleCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "en") == "en/Localizable.strings", "")
    }
    
    func testParseOsxLocaleCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "de") == "de/Localizable.strings", "")
    }
    
    func testParseOsxLocaleCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "en-US") == "en_US/Localizable.strings", "")
    }
    
    func testParseOsxLocaleCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "en_US") == "en_US/Localizable.strings", "")
    }
    
    func testParseOsxLocaleCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "zh-Hant") == "zh-Hant/Localizable.strings", "")
    }
    
    func testParseOsxLocaleCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "zh-Hans") == "zh-Hans/Localizable.strings", "")
    }
    
    // mark - two letters locale

    func testParseTwoLettersLocaleCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%two_letters_code%/Localizable.strings", localization: "en") == "en/Localizable.strings", "")
    }
    
    func testParseTwoLettersLocaleCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%osx_locale%/Localizable.strings", localization: "de") == "de/Localizable.strings", "")
    }
    
    func testParseTwoLettersLocaleCustomPathForEnUSLocalization() {
        XCTAssert(self.pathParser.parse("%two_letters_code%/Localizable.strings", localization: "en-US") == "en/Localizable.strings", "")
    }
    
    func testParseTwoLettersLocaleCustomPathForEnUSWithUnderscoreLocalization() {
        XCTAssert(self.pathParser.parse("%two_letters_code%/Localizable.strings", localization: "en_US") == "en/Localizable.strings", "")
    }
    
    func testParseTwoLettersLocaleCustomPathForZhHantLocalization() {
        XCTAssert(self.pathParser.parse("%two_letters_code%/Localizable.strings", localization: "zh-Hant") == "zh/Localizable.strings", "")
    }
    
    func testParseTwoLettersLocaleCustomPathForZhHansLocalization() {
        XCTAssert(self.pathParser.parse("%two_letters_code%/Localizable.strings", localization: "zh-Hans") == "zh/Localizable.strings", "")
    }
}
