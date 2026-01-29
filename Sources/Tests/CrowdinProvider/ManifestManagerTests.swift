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
}
