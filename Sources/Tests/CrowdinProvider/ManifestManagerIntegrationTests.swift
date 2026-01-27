import XCTest
@testable import CrowdinSDK

class ManifestManagerIntegrationTests: IntegrationTestCase {
    let crowdinTestHash = "5290b1cfa1eb44bf2581e78106i"
    let sourceLanguage = "en"

    override func setUp() {
        super.setUp()
        ManifestManager.clear()
    }

    override func tearDown() {
        ManifestManager.clear()
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
        super.tearDown()
    }

    func testDownloadManifest() {
        let expectation = XCTestExpectation(description: "Manifest download expectation")

        let manifest = ManifestManager.manifest(
            for: crowdinTestHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        XCTAssertFalse(manifest.available)

        manifest.download {
            XCTAssert(manifest.hash == self.crowdinTestHash, "Manifest hash should be same as initial")
            XCTAssert(manifest.available, "Manifest data is downloaded")
            XCTAssertNotNil(manifest.files, "Manifest contain files data")
            XCTAssertNotNil(manifest.timestamp, "Manifest contain timestamp data")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60.0)
    }
}
