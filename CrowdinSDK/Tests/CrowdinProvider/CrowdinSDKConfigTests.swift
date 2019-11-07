import XCTest
@testable import CrowdinSDK

class CrowdinSDKConfigTests: XCTestCase {
    var providerConfig: CrowdinProviderConfig!
    
    override func setUp() {
        self.providerConfig = CrowdinProviderConfig(hashString: "test_hash", localizations: ["en", "de", "uk"], sourceLanguage: "en")
    }
    
    func testProviderConfigInitialization() {
        XCTAssert(providerConfig.hashString == "test_hash")
        
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
