import XCTest
@testable import CrowdinSDK

class ManifestManagerTests: XCTestCase {
    let crowdinTestHash = "5290b1cfa1eb44bf2581e78106i"
    let sourceLanguage = "en"
    override func setUp() {
        
    }
    
    override class func tearDown() {
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
    }
    
    func testDownloadManifest() {
        let expectation = XCTestExpectation(description: "Manifest download expectation")
        
        let manifest = ManifestManager.manifest(for: crowdinTestHash, sourceLanguage: sourceLanguage, organizationName: nil)
        XCTAssertFalse(manifest.loaded)
        XCTAssertFalse(manifest.downloaded)
        
        manifest.download {
            XCTAssert(manifest.hash == self.crowdinTestHash, "Manifest hash should be same as initial")
            
            XCTAssert(manifest.loaded, "Manifest data is loaded")
            XCTAssert(manifest.downloaded, "Manifest data is downloaded")
            
            XCTAssertNotNil(manifest.files, "Manifest contain files data")
            XCTAssertNotNil(manifest.timestamp, "Manifest contain timestamp data")
            
            expectation.fulfill()
        }        
        
        wait(for: [expectation], timeout: 60.0)
    }
}
