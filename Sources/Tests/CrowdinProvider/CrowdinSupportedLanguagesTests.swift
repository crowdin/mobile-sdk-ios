//
//  CrowdinSupportedLanguagesTests.swift
//  CrowdinSDK-Unit-CrowdinProvider_Tests
//
//  Tests for supported languages cache behavior and languages.json parsing.
//

import Foundation
import XCTest
@testable import CrowdinSDK

final class CrowdinSupportedLanguagesTests: XCTestCase {
    private enum Constants {
        static let localizationKey = "supportedLanguages"
        static let filePath = "languages.json"
    }

    override func setUp() {
        super.setUp()
        ManifestManager.clear()
    }

    override func tearDown() {
        ManifestManager.clear()
        super.tearDown()
    }

    func testUpdateSupportedLanguagesUsesCacheWhenTimestampMatches() {
        let hash = "cache-match-hash"
        let fileTimestampStorage = FileTimestampStorage(hash: hash)
        let supportedLanguages = CrowdinSupportedLanguages(hash: hash, fileTimestampStorage: fileTimestampStorage)

        supportedLanguages.supportedLanguages = [makeLanguage(id: "en")]
        fileTimestampStorage.updateTimestamp(for: Constants.localizationKey, filePath: Constants.filePath, timestamp: 123)
        fileTimestampStorage.saveTimestamps()

        let expectation = XCTestExpectation(description: "Completion called without download")
        supportedLanguages.updateSupportedLanguagesIfNeeded(manifestTimestamp: 123, completion: {
            expectation.fulfill()
        }, error: { error in
            XCTFail("Unexpected error: \(error)")
        })

        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(supportedLanguages.loading)
        XCTAssertEqual(supportedLanguages.supportedLanguages?.count, 1)
        XCTAssertEqual(
            fileTimestampStorage.timestamp(for: Constants.localizationKey, filePath: Constants.filePath),
            123
        )
    }

    func testUpdateSupportedLanguagesRefreshesWhenTimestampChanges() {
        let hash = "cache-refresh-hash"
        let fileTimestampStorage = FileTimestampStorage(hash: hash)
        let supportedLanguages = CrowdinSupportedLanguages(hash: hash, fileTimestampStorage: fileTimestampStorage)

        supportedLanguages.supportedLanguages = [makeLanguage(id: "en")]
        fileTimestampStorage.updateTimestamp(for: Constants.localizationKey, filePath: Constants.filePath, timestamp: 1)
        fileTimestampStorage.saveTimestamps()

        CrowdinLanguagesURLProtocolStub.expectedPath = "/\(hash)/languages.json"
        CrowdinLanguagesURLProtocolStub.requestHandler = { request in
            let data = Self.sampleLanguagesJSON()
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Etag": "test-etag"]
            )!
            return (response, data)
        }
        URLProtocol.registerClass(CrowdinLanguagesURLProtocolStub.self)
        defer {
            URLProtocol.unregisterClass(CrowdinLanguagesURLProtocolStub.self)
            CrowdinLanguagesURLProtocolStub.requestHandler = nil
            CrowdinLanguagesURLProtocolStub.expectedPath = nil
            CrowdinLanguagesURLProtocolStub.lastRequest = nil
        }

        let expectation = XCTestExpectation(description: "Completion called after download")
        supportedLanguages.updateSupportedLanguagesIfNeeded(manifestTimestamp: 2, completion: {
            expectation.fulfill()
        }, error: { error in
            XCTFail("Unexpected error: \(error)")
        })

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(supportedLanguages.loading)
        XCTAssertEqual(
            fileTimestampStorage.timestamp(for: Constants.localizationKey, filePath: Constants.filePath),
            2
        )

        let languageIds = supportedLanguages.supportedLanguages?.map { $0.id } ?? []
        XCTAssertEqual(languageIds.sorted(), ["en", "es"].sorted())
        XCTAssertEqual(CrowdinLanguagesURLProtocolStub.lastRequest?.url?.path, "/\(hash)/languages.json")
    }

    private func makeLanguage(id: String) -> DistributionLanguage {
        DistributionLanguage(
            id: id,
            name: "English",
            twoLettersCode: "en",
            threeLettersCode: "eng",
            locale: "en-US",
            localeWithUnderscore: "en_US",
            androidCode: "en-rUS",
            osxCode: "en.lproj",
            osxLocale: "en"
        )
    }

    private static func sampleLanguagesJSON() -> Data {
        let json = """
        {
          "en": {
            "name": "English",
            "two_letters_code": "en",
            "three_letters_code": "eng",
            "locale": "en-US",
            "locale_with_underscore": "en_US",
            "android_code": "en-rUS",
            "osx_code": "en.lproj",
            "osx_locale": "en"
          },
          "es": {
            "name": "Spanish",
            "two_letters_code": "es",
            "three_letters_code": "spa",
            "locale": "es-ES",
            "locale_with_underscore": "es_ES",
            "android_code": "es-rES",
            "osx_code": "es.lproj",
            "osx_locale": "es"
          }
        }
        """
        return Data(json.utf8)
    }
}

final class CrowdinLanguagesURLProtocolStub: URLProtocol {
    static var expectedPath: String?
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        guard url.host == "distributions.crowdin.net" else { return false }
        if let expectedPath = expectedPath {
            return url.path == expectedPath
        }
        return url.path.hasSuffix("/languages.json")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequest = request
        guard let handler = Self.requestHandler else {
            let error = NSError(domain: "CrowdinLanguagesURLProtocolStub", code: 0, userInfo: nil)
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
