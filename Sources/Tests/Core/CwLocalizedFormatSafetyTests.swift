//
//  CwLocalizedFormatSafetyTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  End-to-end regression coverage for CWE-134: an OTA translation must not be
//  trusted as a String(format:) format string when its specifiers don't match
//  the arguments the app supplied. Exercises the real Bundle swizzle ->
//  NSLocalizedString -> cw_localized(with:) path, not just the format check
//  in isolation.
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

/// Stands in for the OTA-backed provider: `localizedString(for:)` returns
/// whatever translation the test wants to simulate a translator having set on
/// Crowdin - the lowest-privileged contributor role.
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

    /// Reproduces the report's PoC: a downloaded translation with more format
    /// specifiers than the app supplied arguments must not reach
    /// String(format:) - it would read past the end of the argument list,
    /// disclosing memory via %x/%p or dereferencing a bad pointer via %@.
    func testCwLocalizedFallsBackWhenOTATranslationHasExcessSpecifiers() {
        let key = "__cwe134_greeting_key__"
        startSDK(translations: [key: "Hallo %@ %x %x %x %x %x %x"])

        let result = key.cw_localized(with: ["Alice"])

        // No bundled resource exists for this key in the test target, so the
        // safe fallback (the app's own bundled localization) returns the key
        // itself - proving the malicious translation was never formatted.
        XCTAssertEqual(result, key)
    }

    /// Same specifier count as the app's argument list, but the wrong category:
    /// %@ in place of %d would dereference the Int's bit pattern as an object
    /// pointer and crash.
    func testCwLocalizedFallsBackWhenOTATranslationSwapsSpecifierCategory() {
        let key = "__cwe134_score_key__"
        startSDK(translations: [key: "Score: %@"])

        let result = key.cw_localized(with: [5])

        XCTAssertEqual(result, key)
    }

    /// A legitimate translation - same specifiers and categories the app
    /// expects, just translated surrounding text - must still be used.
    func testCwLocalizedUsesOTATranslationWhenSpecifiersMatch() {
        let key = "__cwe134_safe_key__"
        startSDK(translations: [key: "Hello %@, you have %d messages"])

        let result = key.cw_localized(with: ["Alice", 3])

        XCTAssertEqual(result, "Hello Alice, you have 3 messages")
    }

    /// Same PoC shape, but each specifier is hidden behind a `%%` literal-percent
    /// escape ("%%%d" = literal "%" + real "%d"). String(format:) still consumes
    /// an argument per "%d", so the translation must be rejected too - on Apple
    /// platforms formatting it with one argument prints several adjacent stack
    /// words (verified: "%-1436743615 %0 %-1198766495 %122 ...").
    func testCwLocalizedFallsBackWhenOTATranslationHidesSpecifiersBehindEscapedPercent() {
        let key = "__cwe134_escaped_greeting_key__"
        startSDK(translations: [key: "%%%d %%%d %%%d %%%d %%%d %%%d"])

        let result = key.cw_localized(with: ["Alice"])

        XCTAssertEqual(result, key)
    }

    /// A legitimate translation that contains a literal percent sign plus one
    /// real specifier must still be used.
    func testCwLocalizedUsesOTATranslationWithLiteralPercentEscape() {
        let key = "__cwe134_percent_key__"
        startSDK(translations: [key: "100%% done: %@"])

        let result = key.cw_localized(with: ["Alice"])

        XCTAssertEqual(result, "100% done: Alice")
    }

    /// `%#x` is a valid specifier the old regex counter did not recognise, so six
    /// of them parsed as zero specifiers and sailed past the argument-count check
    /// (verified: String(format:) printed adjacent stack words such as 0x84836c8).
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
}
