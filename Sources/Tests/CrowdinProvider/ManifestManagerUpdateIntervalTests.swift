//
//  ManifestManagerUpdateIntervalTests.swift
//  CrowdinSDK-Unit-CrowdinProvider_Tests
//
//  Tests for the manifest update interval gate: when the SDK re-downloads
//  the distribution manifest and when it reuses the cached one.
//

import XCTest
@testable import CrowdinSDK

/// Content delivery API stub that returns a fixed manifest without touching the network
/// and counts how many times the manifest was requested.
private final class CountingContentDeliveryAPI: CrowdinContentDeliveryAPI {
    private let lock = NSLock()
    private var _manifestRequests = 0
    var manifestRequests: Int {
        lock.lock()
        defer { lock.unlock() }
        return _manifestRequests
    }

    override func getManifest(completion: @escaping CrowdinAPIManifestCompletion) {
        lock.lock()
        _manifestRequests += 1
        lock.unlock()
        // No timestamp on purpose: a timestamp would trigger a supported languages download.
        let json = """
        {"files": ["/Localizable.strings"], "languages": ["en"], "content": {"en": ["/Localizable.strings"]}, "mapping": []}
        """
        let manifest = try? JSONDecoder().decode(ManifestResponse.self, from: Data(json.utf8))
        DispatchQueue.global().async {
            completion(manifest, "https://distributions.crowdin.net/test/manifest.json", nil)
        }
    }
}

class ManifestManagerUpdateIntervalTests: XCTestCase {
    private var api: CountingContentDeliveryAPI!

    override func setUp() {
        super.setUp()
        ManifestManager.clear()
    }

    override func tearDown() {
        ManifestManager.clear()
        api = nil
        super.tearDown()
    }

    private func makeManager(interval: TimeInterval) -> ManifestManager {
        let hash = "interval_test_" + UUID().uuidString
        let manager = ManifestManager.manifest(
            for: hash,
            sourceLanguage: "en",
            organizationName: nil,
            minimumManifestUpdateInterval: interval
        )
        api = CountingContentDeliveryAPI(hash: hash)
        manager.contentDeliveryAPI = api
        return manager
    }

    private func download(_ manager: ManifestManager, description: String) {
        let expectation = XCTestExpectation(description: description)
        manager.download { expectation.fulfill() }
        wait(for: [expectation], timeout: 5.0)
    }

    func testManifestIsNotDownloadedAgainWithinInterval() {
        let manager = makeManager(interval: 3600)

        download(manager, description: "First download")
        download(manager, description: "Second download within interval")

        XCTAssertEqual(api.manifestRequests, 1)
    }

    func testManifestIsDownloadedAgainOnceIntervalElapsed() {
        let manager = makeManager(interval: 0)

        download(manager, description: "First download")
        download(manager, description: "Second download after interval elapsed")

        XCTAssertEqual(api.manifestRequests, 2)
    }

    func testResetUpdateIntervalForcesManifestDownloadOnNextCall() {
        let manager = makeManager(interval: 3600)

        download(manager, description: "First download")
        manager.resetUpdateInterval()
        download(manager, description: "Download after reset")

        XCTAssertEqual(api.manifestRequests, 2)
    }
}
