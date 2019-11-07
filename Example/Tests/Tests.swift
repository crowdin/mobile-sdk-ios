import XCTest
import CrowdinSDK

class CrowdinSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Setup CrowdinSDK with crowdin sdk with all features:
        let crowdinProviderConfig = CrowdinProviderConfig(hashString: "f78819e9fe3a5fe96d2a383b2ozt",
                                                          localizations: ["en", "de", "uk"],
                                                          sourceLanguage: "en")
//        let loginConfig = CrowdinLoginConfig(clientId: "XjNxVvoJh6XMf8NGnwuG",
//                                             clientSecret: "Dw5TxCKvKQQRcPyAWEkTCZlxRGmcja6AFZNSld6U",
//                                             scope: "project.screenshot",
//											 redirectURI: "crowdintest://",
//											 organizationName: "serhiy")
        let crowdinSDKConfig = CrowdinSDKConfig.config().with(crowdinProviderConfig: crowdinProviderConfig)
//                                                        .with(screenshotsEnabled: true)
//														.with(loginConfig: loginConfig)
//                                                        .with(settingsEnabled: true)
//                                                        .with(reatimeUpdatesEnabled: true)
        CrowdinSDK.startWithConfig(crowdinSDKConfig)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInSDKLocalizations() {
        XCTAssert(CrowdinSDK.inSDKLocalizations.count == 3, "Current SDK setup supports 3 localization.")
    }
}
