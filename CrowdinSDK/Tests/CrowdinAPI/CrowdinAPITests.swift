import XCTest
@testable import CrowdinSDK

class CrowdinSDKConfigCrowdinAPITests: XCTestCase {
    var providerConfig: CrowdinProviderConfig!
    
    override func setUp() {
        self.providerConfig = CrowdinProviderConfig(hashString: "test_hash", stringsFileNames: ["string_file_1", "string_file_2"], pluralsFileNames: ["plural_file_1", "plural_file_2", "plural_file_3"], localizations: ["en", "de", "uk"], sourceLanguage: "en")
    }
    
    func testProviderConfigInitialization() {
        let providerConfig = CrowdinProviderConfig(hashString: "test_hash", stringsFileNames: ["string_file_1", "string_file_2"], pluralsFileNames: ["plural_file_1", "plural_file_2", "plural_file_3"], localizations: ["en", "de", "uk"], sourceLanguage: "en")
        
        XCTAssert(providerConfig.hashString == "test_hash")
        
        XCTAssert(providerConfig.stringsFileNames.count == 2)
        XCTAssert(providerConfig.stringsFileNames.contains("string_file_1"))
        XCTAssert(providerConfig.stringsFileNames.contains("string_file_2"))
        
        XCTAssert(providerConfig.pluralsFileNames.count == 3)
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_1"))
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_2"))
        XCTAssert(providerConfig.pluralsFileNames.contains("plural_file_3"))
        
        
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
