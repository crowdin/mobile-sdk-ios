import XCTest
@testable import CrowdinSDK

class CrowdinAPITests: XCTestCase {
    // swiftlint:disable implicitly_unwrapped_optional
    var api: CrowdinAPI!
    
    func testAPIInitialization() {
        api = CrowdinAPI(organizationName: nil)
        
        XCTAssert(api.baseURL == "https://api.crowdin.com/api/v2/")
        XCTAssert(api.apiPath == "")
        XCTAssertNil(api.organizationName)
        XCTAssert(api.fullPath == "https://api.crowdin.com/api/v2/")
    }
    
    func testAPIInitializationWithOrganization() {
        api = CrowdinAPI(organizationName: "test")
        
        XCTAssert(api.baseURL == "https://test.api.crowdin.com/api/v2/")
        XCTAssert(api.apiPath == "")
        XCTAssert(api.organizationName == "test")
        XCTAssert(api.fullPath == "https://test.api.crowdin.com/api/v2/")
    }

    func testUserAgentHeader() {
        api = CrowdinAPI(organizationName: nil)
        let headers = CrowdinAPI.versioned(nil)
        XCTAssertNotNil(headers["User-Agent"])
        let userAgent = headers["User-Agent"]!
        XCTAssertTrue(userAgent.contains("crowdin-ios-sdk/"))
        
        #if os(iOS) || os(tvOS)
        XCTAssertTrue(userAgent.contains("iOS/"))
        #elseif os(watchOS)
        XCTAssertTrue(userAgent.contains("watchOS/"))
        #elseif os(macOS)
        XCTAssertTrue(userAgent.contains("macOS/"))
        #endif
    }
}
