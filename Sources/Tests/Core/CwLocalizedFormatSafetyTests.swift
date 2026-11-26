//
//  CwLocalizedFormatSafetyTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  End-to-end CWE-134 tests: Bundle swizzle -> NSLocalizedString -> cw_localized(with:).
//

import XCTest
@testable import CrowdinSDK

private class FormatSafetyLocalStorage: LocalLocalizationStorageProtocol {
    var localization: String
    var localizations: [String] { [] }
    var strings: [String: String] = [:]
    var plurals: [AnyHashable: Any] = [:]

    init(localization: String) { self.localization = localization }

    func fetchData(completion: LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        completion(localizations, localization, strings, plurals)
    }
    func saveLocalizaion(strings: [String: String]?, plurals: [AnyHashable: Any]?, for localization: String) {}
    func save() {}
    func fetchData() {}
    func deintegrate() {}
}

private class FormatSafetyRemoteStorage: RemoteLocalizationStorageProtocol {
    var localization: String
    var localizations: [String] = []
    var name: String = "FormatSafetyRemoteStorage"

    init(localization: String) { self.localization = localization }

    func prepare(with completion: @escaping () -> Void) { completion() }
    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        completion(localizations, localization, [:], [:])
    }
    func deintegrate() {}
}

/// Stub provider returning arbitrary OTA translations.
private class MaliciousTranslationProvider: LocalizationProviderProtocol {
    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol
    var localization: String
    var localizations: [String] { [] }
    var translations: [String: String] = [:]

    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
    }

    func refreshLocalization() {}
    func refreshLocalization(completion: @escaping ((Error?) -> Void)) { completion(nil) }
    func setLocalization(_ localization: String, completion: @escaping ((Error?) -> Void)) {
        self.localization = localization
        completion(nil)
    }
    func prepare(with completion: @escaping () -> Void) { completion() }
    func deintegrate() {}

    func localizedString(for key: String) -> String? { translations[key] }
    func key(for string: String) -> String? { nil }
    func values(for string: String, with format: String) -> [Any]? { nil }
    func set(string: String, for key: String) { translations[key] = string }
}

class CwLocalizedFormatSafetyTests: XCTestCase {
    private var provider: MaliciousTranslationProvider?

    override func tearDown() {
        Bundle.unswizzle()
        Localization.current = nil
        provider = nil
        super.tearDown()
    }

    private func startSDK(translations: [String: String]) {
        let local = FormatSafetyLocalStorage(localization: "en")
        let remote = FormatSafetyRemoteStorage(localization: "en")
        let provider = MaliciousTranslationProvider(localization: "en", localStorage: local, remoteStorage: remote)
        provider.translations = translations
        Localization.current = Localization(provider: provider)
        Bundle.swizzle()
        self.provider = provider
    }

    func testCwLocalizedFallsBackWhenOTATranslationHasExcessSpecifiers() {
        let key = "__cwe134_greeting_key__"
        startSDK(translations: [key: "Hallo %@ %x %x %x %x %x %x"])

        let result = key.cw_localized(with: ["Alice"])

        // Unbundled test keys fall back to the key itself, confirming the OTA string was skipped.
        XCTAssertEqual(result, key)
    }

    /// `%@` for an `Int` would dereference the integer as an object pointer.
    func testCwLocalizedFallsBackWhenOTATranslationSwapsSpecifierCategory() {
        let key = "__cwe134_score_key__"
        startSDK(translations: [key: "Score: %@"])

        let result = key.cw_localized(with: [5])

        XCTAssertEqual(result, key)
    }

    func testCwLocalizedUsesOTATranslationWhenSpecifiersMatch() {
        let key = "__cwe134_safe_key__"
        startSDK(translations: [key: "Hello %@, you have %d messages"])

        let result = key.cw_localized(with: ["Alice", 3])

        XCTAssertEqual(result, "Hello Alice, you have 3 messages")
    }

    /// Specifiers after `%%` escapes (`%%%d` = literal `%` + `%d`) still consume arguments.
    func testCwLocalizedFallsBackWhenOTATranslationHidesSpecifiersBehindEscapedPercent() {
        let key = "__cwe134_escaped_greeting_key__"
        startSDK(translations: [key: "%%%d %%%d %%%d %%%d %%%d %%%d"])

        let result = key.cw_localized(with: ["Alice"])

        XCTAssertEqual(result, key)
    }

    func testCwLocalizedUsesOTATranslationWithLiteralPercentEscape() {
        let key = "__cwe134_percent_key__"
        startSDK(translations: [key: "100%% done: %@"])

        let result = key.cw_localized(with: ["Alice"])

        XCTAssertEqual(result, "100% done: Alice")
    }

    /// `%#x` must be counted as a specifier so excess arguments are rejected.
    func testCwLocalizedFallsBackWhenOTATranslationUsesFlaggedSpecifiers() {
        let key = "__cwe134_flagged_key__"
        startSDK(translations: [key: "%#x %#x %#x %#x %#x %#x"])

        XCTAssertEqual(key.cw_localized(with: [3]), key)
    }

    func testCwLocalizedFallsBackWhenOTATranslationUsesStarWidth() {
        let key = "__cwe134_star_key__"
        startSDK(translations: [key: "%*d%*d%*d%*d"])

        XCTAssertEqual(key.cw_localized(with: [3]), key)
    }

    func testCwLocalizedFallsBackWhenOTATranslationHidesSpecifiersInsideReferenceName() {
        let key = "__cwe134_ref_bypass_key__"
        startSDK(translations: [key: "%#@a%p%p%p%p@"])

        XCTAssertEqual(key.cw_localized(with: ["Alice"]), key)
    }

    func testCwLocalizedFallsBackWhenOTATranslationUsesTripleLengthOrReorderedModifiers() {
        let key1 = "__cwe134_lll_key__"
        let key2 = "__cwe134_reordered_key__"
        startSDK(translations: [
            key1: "%lllp %lllp %lllp",
            key2: "%l+p %5-p %l5p"
        ])

        XCTAssertEqual(key1.cw_localized(with: []), key1)
        XCTAssertEqual(key2.cw_localized(with: []), key2)
    }

    /// `%P` (lowercased to `%p` before the fix) crashed CoreFoundation instead of falling back.
    func testCwLocalizedFallsBackWhenOTATranslationUsesUppercasePointer() {
        let key = "__cwe134_uppercase_pointer_key__"
        startSDK(translations: [key: "Items: %P"])

        XCTAssertEqual(key.cw_localized(with: [3]), key)
    }

    /// `%#@ @` is parsed by CoreFoundation as `%#@` (object) and crashed on a scalar argument.
    func testCwLocalizedFallsBackWhenOTATranslationUsesNonIdentifierReferenceName() {
        let key = "__cwe134_odd_reference_key__"
        startSDK(translations: [key: "Items: %#@ @"])

        XCTAssertEqual(key.cw_localized(with: [3]), key)
    }
}
