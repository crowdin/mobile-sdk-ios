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
    
    func testParseLanguageCustomPathForEnLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "en") == "en-US/Localizable.strings", "")
    }
    
    func testParseLanguageCustomPathForDeLocalization() {
        XCTAssert(self.pathParser.parse("%locale%/Localizable.strings", localization: "de") == "de/Localizable.strings", "")
    }
}
