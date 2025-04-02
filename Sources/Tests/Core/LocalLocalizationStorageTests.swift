import XCTest
@testable import CrowdinSDK

class LocalLocalizationStorageTests: XCTestCase {
    override class func setUp() {
        // Clear all crowdin data:
        CrowdinSDK.deintegrate()
    }
   
    // swiftlint:disable implicitly_unwrapped_optional
    var localLocalizationStorage: LocalLocalizationStorage!
    
    override func tearDown() {
        localLocalizationStorage.deintegrate()
        localLocalizationStorage = nil
    }
    
    func testLocalLocalizationStorageInit() {
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        
        XCTAssertNotNil(localLocalizationStorage)
        XCTAssertNotNil(localLocalizationStorage.localizationFolder)
        XCTAssertTrue(localLocalizationStorage.localization == "en")
        XCTAssertTrue(localLocalizationStorage.localizations == [])
        XCTAssertTrue(localLocalizationStorage.strings.isEmpty)
        XCTAssertTrue(localLocalizationStorage.plurals.isEmpty)
    }
    
    private let stringsDictEn = [
        "test_key_en": "test_value_en"
    ]
    private let stringsDictDe = [
        "test_key_de": "test_value_de"
    ]
    
    func testSaveLocalizationStrings() {
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        localLocalizationStorage.strings = stringsDictEn
        localLocalizationStorage.save()
                                            
        XCTAssertTrue(localLocalizationStorage.localizations == ["en"])
        XCTAssertTrue(localLocalizationStorage.strings.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.strings.keys.contains("test_key_en"))
        XCTAssertTrue(localLocalizationStorage.strings.values.contains("test_value_en"))
        XCTAssertTrue(localLocalizationStorage.strings == stringsDictEn)
    }
    
    func testSaveAndReadLocalizationStrings() {
        self.testSaveLocalizationStrings() // Save strings: ["test_key": "test_value"]
        localLocalizationStorage = nil
        
        // Create new object and read strings:
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        localLocalizationStorage.fetchData()
        
        XCTAssertTrue(localLocalizationStorage.localizations == ["en"])
        XCTAssertTrue(localLocalizationStorage.strings.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.strings.keys.contains("test_key_en"))
        XCTAssertTrue(localLocalizationStorage.strings.values.contains("test_value_en"))
        XCTAssertTrue(localLocalizationStorage.strings == stringsDictEn)
    }
    
    private let pluralsDictEn: [String: AnyHashable] = [
        "test_key_en": [
            "NSStringLocalizedFormatKey": [
                "I have %#@test_value_en@.": [
                    "test_value_en": [
                        "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                        "NSStringFormatValueTypeKey": "d",
                        "zero": "empty",
                        "one": "1 think",
                        "other": "%d thinks"
                    ]
                ]
            ]
        ]
    ]
    private let pluralsDictDe: [String: AnyHashable] = [
        "test_key_de": [
            "NSStringLocalizedFormatKey": [
                "I have %#@test_value_de@.": [
                    "test_value_de": [
                        "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                        "NSStringFormatValueTypeKey": "d",
                        "zero": "empty",
                        "one": "1 think",
                        "other": "%d thinks"
                    ]
                ]
            ]
        ]
    ]
    
    func testSaveLocalizationPlurals() {
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        localLocalizationStorage.plurals = pluralsDictEn
        
        localLocalizationStorage.save()
                                            
        XCTAssertTrue(localLocalizationStorage.localizations == ["en"])
        XCTAssertTrue(localLocalizationStorage.plurals.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.plurals.keys.contains("test_key_en"))
        // swiftlint:disable force_cast
        XCTAssertTrue(localLocalizationStorage.plurals as! [String: AnyHashable] == pluralsDictEn)
    }
    
    func testSaveAndReadLocalizationPlurals() {
        self.testSaveLocalizationPlurals()
        
        localLocalizationStorage = nil
        
        // Create new object and read strings:
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        localLocalizationStorage.fetchData()
        
        XCTAssertTrue(localLocalizationStorage.localizations == ["en"])
        XCTAssertTrue(localLocalizationStorage.plurals.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.plurals.keys.contains("test_key_en"))
        // swiftlint:disable force_cast
        XCTAssertTrue(localLocalizationStorage.plurals as! [String: AnyHashable] == pluralsDictEn)
    }
    
    func testSaveTwoLocalizations() {
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        
        localLocalizationStorage.saveLocalizaion(strings: stringsDictEn, plurals: pluralsDictEn, for: "en")
        localLocalizationStorage.localization = "de"
        localLocalizationStorage.saveLocalizaion(strings: stringsDictDe, plurals: pluralsDictDe, for: "de")
        
        localLocalizationStorage = nil
        
        localLocalizationStorage = LocalLocalizationStorage(localization: "en")
        
        localLocalizationStorage.fetchData()
        
        XCTAssertTrue(localLocalizationStorage.localizations.count == 2)
        XCTAssertTrue(localLocalizationStorage.localizations == ["en", "de"])
        
        XCTAssertTrue(localLocalizationStorage.localization == "en")
        
        // Check strings:
        XCTAssertTrue(localLocalizationStorage.strings.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.strings.keys.contains("test_key_en"))
        XCTAssertTrue(localLocalizationStorage.strings.values.contains("test_value_en"))
        XCTAssertTrue(localLocalizationStorage.strings == stringsDictEn)
        
        // Check plurals:
        XCTAssertTrue(localLocalizationStorage.plurals.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.plurals.keys.contains("test_key_en"))
        // swiftlint:disable force_cast
        XCTAssertTrue(localLocalizationStorage.plurals as! [String: AnyHashable] == pluralsDictEn)
        
        // Switch language:
        localLocalizationStorage.localization = "de"
        
        // Check strings:
        XCTAssertTrue(localLocalizationStorage.strings.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.strings.keys.contains("test_key_de"))
        XCTAssertTrue(localLocalizationStorage.strings.values.contains("test_value_de"))
        XCTAssertTrue(localLocalizationStorage.strings == stringsDictDe)
        
        // Check plurals:
        XCTAssertTrue(localLocalizationStorage.plurals.keys.count == 1)
        XCTAssertTrue(localLocalizationStorage.plurals.keys.contains("test_key_de"))
        XCTAssertTrue(localLocalizationStorage.plurals as! [String: AnyHashable] == pluralsDictDe)
    }
}
