import XCTest
@testable import CrowdinSDK

class CrowdinSDKConfigTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEmptyConfig() {
        let config = CrowdinSDKConfig.config()
        XCTAssertNil(config.crowdinProviderConfig)
    }
    
    
}
