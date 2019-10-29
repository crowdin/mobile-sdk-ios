import XCTest
@testable import CrowdinSDK

class CrowdinAPITests: XCTestCase {
    var api: CrowdinAPI!
    
    override func setUp() {
    }
    
    func testAPIInitialization() {
        api = CrowdinAPI()
        
        XCTAssert(api.baseURL == "https://crowdin.com/api/v2/")
        XCTAssert(api.apiPath == "")
        XCTAssertNil(api.organizationName)
        XCTAssert(api.fullPath == "https://crowdin.com/api/v2/")
    }
    
    func testAPIInitializationWithOrganization() {
        api = CrowdinAPI(organizationName: "test")
        
        XCTAssert(api.baseURL == "https://test.crowdin.com/api/v2/")
        XCTAssert(api.apiPath == "")
        XCTAssert(api.organizationName == "test")
        XCTAssert(api.fullPath == "https://test.crowdin.com/api/v2/")
    }
}
