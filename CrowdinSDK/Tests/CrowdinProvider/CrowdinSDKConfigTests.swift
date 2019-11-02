import XCTest
@testable import CrowdinSDK

class CrowdinSDKConfigTests: XCTestCase {
    var providerConfig: CrowdinProviderConfig!
    
    override func setUp() {
        self.providerConfig = CrowdinProviderConfig(hashString: "test_hash", files: ["string_file_1.strings", "string_file_2.strings", "plural_file_1.stringsdict", "plural_file_2.stringsdict", "plural_file_3.stringsdict"], localizations: ["en", "de", "uk"], sourceLanguage: "en")
    }
    
    func testProviderConfigInitialization() {
        XCTAssert(providerConfig.hashString == "test_hash")
        
        XCTAssert(providerConfig.stringsFileNames.count == 2)
        XCTAssert(providerConfig.stringsFileNames.contains("string_file_1.strings"))
        XCTAssert(providerConfig.stringsFileNames.contains("string_file_2.strings"))
        
        XCTAssert(providerConfig.pluralsFileNames.count == 3)
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_1.stringsdict"))
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_2.stringsdict"))
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_3.stringsdict"))
        
        
        XCTAssert(providerConfig.localizations.count == 3)
        XCTAssert(providerConfig.localizations.contains("en"))
        XCTAssert(providerConfig.localizations.contains("de"))
        XCTAssert(providerConfig.localizations.contains("uk"))
        
        XCTAssert(providerConfig.sourceLanguage == "en")
    }
    
    func testConfigInitialization() {
        let config = CrowdinSDKConfig.config().with(crowdinProviderConfig: providerConfig)
        XCTAssertNotNil(config.crowdinProviderConfig)
    }
}
