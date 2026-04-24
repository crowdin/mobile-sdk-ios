import XCTest
@testable import CrowdinSDK

class ManifestManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ManifestManager.clear()
    }
    
    override class func tearDown() {
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
        ManifestManager.clear()
    }
    
    func testContentFilesForSpanishAndSwedish() {
        let manifestManager = ManifestManager.manifest(for: "test_hash", sourceLanguage: "en", organizationName: nil, minimumManifestUpdateInterval: 60)
        
        // 1. Setup Supported Languages (Mocking what Crowdin returns)
        struct MockLanguage: CrowdinLanguage {
            var id: String
            var name: String
            var twoLettersCode: String
            var threeLettersCode: String
            var locale: String
            var osxCode: String
            var osxLocale: String
        }
        
        let esLang = MockLanguage(id: "es-ES", name: "Spanish", twoLettersCode: "es", threeLettersCode: "spa", locale: "es-ES", osxCode: "es.lproj", osxLocale: "es")
        let svLang = MockLanguage(id: "sv-SE", name: "Swedish", twoLettersCode: "sv", threeLettersCode: "swe", locale: "sv-SE", osxCode: "sv.lproj", osxLocale: "sv")

        manifestManager.crowdinSupportedLanguages.supportedLanguages = [esLang, svLang]
        
        // 2. Setup Manifest (Mocking user's manifest)
        let content: [String: [String]] = [
            "es": ["/content/es.strings"],
            "sv": ["/content/sv.strings"]
        ]
        let manifestResponse = ManifestResponse(
            files: ["/Localizable.strings"],
            timestamp: 1234567890,
            languages: ["es", "sv"],
            responseCustomLanguages: nil,
            content: content,
            mapping: []
        )
        
        manifestManager.manifest = manifestResponse
        
        // 3. Test Spanish
        // "es" iOS code -> matches "es-ES" supported language (osxLocale="es") -> id="es-ES"
        // Manifest has "es".
        // Expectation: Should find files for "es" even if id is "es-ES"
        let esFiles = manifestManager.contentFiles(for: "es")
        XCTAssertEqual(esFiles, ["/content/es.strings"], "Should find Spanish files")
        
        // 4. Test Swedish
        // "sv" iOS code -> matches "sv-SE" supported language (osxLocale="sv") -> id="sv-SE"
        // Manifest has "sv".
        // Expectation: Should find files for "sv" even if id is "sv-SE"
        let svFiles = manifestManager.contentFiles(for: "sv")
        XCTAssertEqual(svFiles, ["/content/sv.strings"], "Should find Swedish files")
        
        // Cleanup
        manifestManager.clear()
    }

    func testContentFilesForCustomLanguage() {
        let manifestManager = ManifestManager.manifest(for: "test_hash_custom", sourceLanguage: "en", organizationName: nil, minimumManifestUpdateInterval: 60)

        let customLanguage = ManifestResponse.ManifestResponseCustomLangugage(
            locale: "tlh-PQ",
            twoLettersCode: "tlh",
            threeLettersCode: "tlh",
            localeWithUnderscore: "tlh_PQ",
            androidCode: "tlh-rPQ",
            osxCode: "tlh.lproj",
            osxLocale: "tlh"
        )

        let manifestResponse = ManifestResponse(
            files: ["/Localizable.strings"],
            timestamp: 1234567890,
            languages: ["tlh-PQ"],
            responseCustomLanguages: ["tlh-PQ": customLanguage],
            content: ["tlh-PQ": ["/content/tlh.strings"]],
            mapping: []
        )

        manifestManager.manifest = manifestResponse

        let customFiles = manifestManager.contentFiles(for: "tlh")
        XCTAssertEqual(customFiles, ["/content/tlh.strings"], "Should find custom language files")

        manifestManager.clear()
    }

    func testXcstringsParsingKeyForStandardLanguage() {
        let manifestManager = ManifestManager.manifest(for: "test_hash_xcstrings_standard", sourceLanguage: "en", organizationName: nil, minimumManifestUpdateInterval: 60)

        struct MockLanguage: CrowdinLanguage {
            var id: String
            var name: String
            var twoLettersCode: String
            var threeLettersCode: String
            var locale: String
            var osxCode: String
            var osxLocale: String
        }

        let deLang = MockLanguage(id: "de", name: "German", twoLettersCode: "de", threeLettersCode: "deu", locale: "de-DE", osxCode: "de.lproj", osxLocale: "de")
        let ptBRLang = MockLanguage(id: "pt-BR", name: "Portuguese, Brazilian", twoLettersCode: "pt", threeLettersCode: "por", locale: "pt-BR", osxCode: "pt_BR.lproj", osxLocale: "pt-BR")

        manifestManager.crowdinSupportedLanguages.supportedLanguages = [deLang, ptBRLang]
        manifestManager.manifest = ManifestResponse(
            files: [],
            timestamp: 0,
            languages: ["de", "pt-BR"],
            responseCustomLanguages: nil,
            content: [:],
            mapping: []
        )

        // Standard language: returns iOSLanguageCode normalized to BCP 47
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "de"), "de")
        // Standard language passed with underscore: returns iOSLanguageCode ("pt-BR"), not raw input "pt_BR"
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "pt_BR"), "pt-BR")
        // Unknown language with underscore: normalizes underscore to hyphen
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "zh_HK"), "zh-HK")
        // Unknown language already in BCP 47 format: returned as-is
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "zh-HK"), "zh-HK")

        manifestManager.clear()
    }

    func testXcstringsParsingKeyForCustomLanguage() {
        let manifestManager = ManifestManager.manifest(for: "test_hash_xcstrings_custom", sourceLanguage: "en", organizationName: nil, minimumManifestUpdateInterval: 60)

        // Custom Tongan: osxLocale="to", locale="to-To" → redundant region stripped → "to"
        let toCustomLanguage = ManifestResponse.ManifestResponseCustomLangugage(
            locale: "to-To",
            twoLettersCode: "to",
            threeLettersCode: "ton",
            localeWithUnderscore: "to_To",
            androidCode: "to-rTo",
            osxCode: "to.lproj",
            osxLocale: "to"
        )

        // Custom Serbian (Kosovo): osxLocale="SRXK", locale="sr_XK" → normalized to "sr-XK"
        let srXKCustomLanguage = ManifestResponse.ManifestResponseCustomLangugage(
            locale: "sr_XK",
            twoLettersCode: "sr",
            threeLettersCode: "srp",
            localeWithUnderscore: "sr_XK",
            androidCode: "sr-rXK",
            osxCode: "SRXK.lproj",
            osxLocale: "SRXK"
        )

        manifestManager.manifest = ManifestResponse(
            files: [],
            timestamp: 0,
            languages: ["to-To", "sr-XK"],
            responseCustomLanguages: ["to-To": toCustomLanguage, "sr-XK": srXKCustomLanguage],
            content: [:],
            mapping: []
        )

        // Custom Tongan: iOSLanguageCode = osxLocale = "to" → xcstrings key = "to"
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "to"), "to")
        // Custom Serbian Kosovo: iOSLanguageCode = osxLocale = "SRXK" → xcstrings key = "sr-XK"
        XCTAssertEqual(manifestManager.xcstringsParsingKey(for: "SRXK"), "sr-XK")

        manifestManager.clear()
    }
}
