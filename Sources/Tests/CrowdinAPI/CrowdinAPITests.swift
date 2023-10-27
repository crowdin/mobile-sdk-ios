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
}
