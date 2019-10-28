import XCTest
@testable import CrowdinSDK

class CrowdinLoginConfigTests: XCTestCase {
    var loginConfig: CrowdinLoginConfig!
    
    override func setUp() {
        
    }
    
    func testLoginConfigInit() {
        loginConfig = CrowdinLoginConfig(clientId: "clientId", clientSecret: "clientSecret", scope: "scope", redirectURI: "crowdintest://")
        
        XCTAssertNotNil(loginConfig)
        XCTAssert(loginConfig.clientId == "clientId")
        XCTAssert(loginConfig.clientSecret == "clientSecret")
        XCTAssert(loginConfig.scope == "scope")
        XCTAssert(loginConfig.redirectURI == "crowdintest://")
    }
    
    func testLoginConfigOrganizationInit() {
        loginConfig = CrowdinLoginConfig(clientId: "clientId", clientSecret: "clientSecret", scope: "scope", redirectURI: "crowdintest://", organizationName: "organizationName")
        
        XCTAssertNotNil(loginConfig)
        XCTAssert(loginConfig.clientId == "clientId")
        XCTAssert(loginConfig.clientSecret == "clientSecret")
        XCTAssert(loginConfig.scope == "scope")
        XCTAssert(loginConfig.redirectURI == "crowdintest://")
        XCTAssert(loginConfig.organizationName == "organizationName")
    }
}
