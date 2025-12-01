//
//  BundleSwizzleReentrancyTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Validates that swizzled Bundle.localizedString avoids recursion when system APIs
//  like NSError.localizedDescription trigger nested localization during resolution.
//

import XCTest
@testable import CrowdinSDK

private class DummyLocalStorage: LocalLocalizationStorageProtocol {
    var localization: String
    var localizations: [String] { [] }
    var strings: [String: String] = [:]
    var plurals: [AnyHashable: Any] = [:]

    init(localization: String) {
        self.localization = localization
    }

    func fetchData(completion: LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        completion(localizations, localization, strings, plurals)
    }

    func saveLocalizaion(strings: [String: String]?, plurals: [AnyHashable: Any]?, for localization: String) { }
    func save() { }
    func fetchData() { }
    func deintegrate() { }
}

private class DummyRemoteStorage: RemoteLocalizationStorageProtocol {
    var localization: String
    var localizations: [String] = []
    var name: String = "DummyRemoteStorage"

    init(localization: String) {
        self.localization = localization
    }

    func prepare(with completion: @escaping () -> Void) { completion() }

    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        completion(localizations, localization, [:], [:])
    }

    func deintegrate() { }
}

private class ReentrantProvider: LocalizationProviderProtocol {
    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol
    var localization: String
    var localizations: [String] { [] }

    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
    }

    func refreshLocalization() { }
    func refreshLocalization(completion: @escaping ((Error?) -> Void)) { completion(nil) }
    func prepare(with completion: @escaping () -> Void) { completion() }
    func deintegrate() { }

    func localizedString(for key: String) -> String? {
        // Force a direct recursive path through the swizzled method
        _ = Bundle.main.localizedString(forKey: "__reentrancy_inner__", value: nil, table: nil)
        return nil
    }

    func key(for string: String) -> String? { nil }
    func values(for string: String, with format: String) -> [Any]? { nil }
    func set(string: String, for key: String) { }
}

private class NSErrorReentrantProvider: LocalizationProviderProtocol {
    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol
    var localization: String
    var localizations: [String] { [] }

    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
    }

    func refreshLocalization() { }
    func refreshLocalization(completion: @escaping ((Error?) -> Void)) { completion(nil) }
    func prepare(with completion: @escaping () -> Void) { completion() }
    func deintegrate() { }

    func localizedString(for key: String) -> String? {
        // Trigger system error description which internally performs localized string lookup
        _ = NSError(domain: "test-domain", code: 999, userInfo: nil).localizedDescription
        return nil
    }

    func key(for string: String) -> String? { nil }
    func values(for string: String, with format: String) -> [Any]? { nil }
    func set(string: String, for key: String) { }
}

class BundleSwizzleReentrancyTests: XCTestCase {
    override func tearDown() {
        Bundle.unswizzle()
        Localization.current = nil
    }

    func testSwizzledBundleLocalizedStringDoesNotRecurseOnNSError() {
        Bundle.swizzle()
        defer {
            Bundle.unswizzle()
            Localization.current = nil
        }

        let local = DummyLocalStorage(localization: "en")
        let remote = DummyRemoteStorage(localization: "en")
        let provider = ReentrantProvider(localization: "en", localStorage: local, remoteStorage: remote)
        Localization.current = Localization(provider: provider)

        // If recursion occurs, this would crash; with the guard it should safely return the key
        let key = "__reentrancy_test_key__"
        let value = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        XCTAssertEqual(value, key)
    }

    func testSwizzledBundleLocalizedStringHandlesNSErrorReentrancy() {
        Bundle.swizzle()
        defer {
            Bundle.unswizzle()
            Localization.current = nil
        }

        let local = DummyLocalStorage(localization: "en")
        let remote = DummyRemoteStorage(localization: "en")
        let provider = NSErrorReentrantProvider(localization: "en", localStorage: local, remoteStorage: remote)
        Localization.current = Localization(provider: provider)

        let key = "__nserror_reentrancy_test_key__"
        let value = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        XCTAssertEqual(value, key)
    }
}
