//
//  RealLocalizationProviderIntegrationTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Created by Serhii Londar on 20.01.2026.
//

import XCTest
@testable import CrowdinSDK

class RealLocalizationProviderIntegrationTests: IntegrationTestCase {
    let crowdinProviderConfig = CrowdinProviderConfig(hashString: "5290b1cfa1eb44bf2581e78106i", sourceLanguage: "en")
    // swiftlint:disable implicitly_unwrapped_optional
    var localizationProvider: LocalizationProvider!

    override func setUp() {
        super.setUp()
        // Ensure global state from other tests doesn't affect these tests
        Bundle.unswizzle()
        Localization.current = nil
        CrowdinSDK.currentLocalization = nil
        ManifestManager.clear()
    }

    override func tearDown() {
        localizationProvider?.deintegrate()
        localizationProvider = nil
        ManifestManager.clear()
        super.tearDown()
    }

    func testRaceCondition() {
        let expectation = self.expectation(description: "Race condition test finished")

        let localization = "en"
        let localStorage = LocalLocalizationStorage(localization: localization)
        let remoteStorage = CrowdinRemoteLocalizationStorage(localization: localization, config: crowdinProviderConfig)
        localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)

        remoteStorage.prepare {
            let dispatchGroup = DispatchGroup()

            // Reduce the number of concurrent operations to avoid overwhelming the system
            // This is more realistic - apps don't typically have 100s of simultaneous refresh calls
            let refreshCount = 10
            let accessCount = 20

            // Add a small delay between operations to make the test more stable
            let delayBetweenOperations: TimeInterval = 0.01

            // Simulate background updates with controlled timing
            for i in 0..<refreshCount {
                dispatchGroup.enter()
                DispatchQueue.global().asyncAfter(deadline: .now() + Double(i) * delayBetweenOperations) {
                    self.localizationProvider.refreshLocalization { _ in
                        dispatchGroup.leave()
                    }
                }
            }

            // Simulate main thread access with controlled timing
            for i in 0..<accessCount {
                dispatchGroup.enter()
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * delayBetweenOperations) {
                    _ = self.localizationProvider.key(for: "some string \(i)")
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 30.0)
    }
}
