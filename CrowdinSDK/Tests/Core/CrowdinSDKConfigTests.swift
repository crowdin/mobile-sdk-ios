import XCTest
@testable import CrowdinSDK

class CrowdinSDKConfigTests: XCTestCase {
    func testConfigInitialization() {
        let config = CrowdinSDKConfig.config()
        XCTAssertNil(config.crowdinProviderConfig)
    }
}
