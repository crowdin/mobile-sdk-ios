//
//  CrowdinSocketManagerTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 23.08.2026.
//  Copyright © 2026 Crowdin. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class CrowdinSocketManagerTests: XCTestCase {
    private class MockLanguageResolver: LanguageResolver {
        func crowdinLanguageCode(for localization: String) -> String? {
            return localization
        }
        
        func crowdinSupportedLanguage(for localization: String) -> CrowdinLanguage? {
            return nil
        }
        
        func iOSLanguageCode(for crowdinLocalization: String) -> String? {
            return crowdinLocalization
        }
    }
    
    private var socketManager: CrowdinSocketManager!
    
    override func setUp() {
        super.setUp()
        socketManager = CrowdinSocketManager(
            hashString: "test_hash",
            projectId: "1",
            projectWsHash: "ws_hash",
            userId: "2",
            wsUrl: "https://ws.crowdin.com",
            languageResolver: MockLanguageResolver()
        )
    }
    
    override func tearDown() {
        socketManager = nil
        super.tearDown()
    }
    
    func testParseIdDirectInt() {
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "14477"), 14477)
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "0"), 0)
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "123456789"), 123456789)
    }
    
    func testParseIdTrFormatted() {
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "tr{14477}"), 14477)
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "tr{0}"), 0)
        XCTAssertEqual(CrowdinSocketManager.parseId(from: "tr{999999}"), 999999)
    }
    
    func testParseIdInvalidFormats() {
        XCTAssertNil(CrowdinSocketManager.parseId(from: ""))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "abc"))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "tr{abc}"))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "tr{}"))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "tr{123"))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "123}"))
        XCTAssertNil(CrowdinSocketManager.parseId(from: "tr{123}extra"))
    }
    
    func testUpdateDraftWithStringChangeTrFormat() {
        var changedId: Int?
        var changedText: String?
        
        socketManager.didChangeString = { id, text in
            changedId = id
            changedText = text
        }
        
        let draftResponse = UpdateDraftResponse(
            event: "update-draft:wsHash:pr{1}:us{2}:en:tr{14477}",
            data: UpdateDraftResponseData(text: "New Translated Text", pluralForm: "none")
        )
        
        socketManager.updateDraft(draftResponse)
        
        XCTAssertEqual(changedId, 14477)
        XCTAssertEqual(changedText, "New Translated Text")
    }
    
    func testUpdateDraftWithStringChangePlainFormat() {
        var changedId: Int?
        var changedText: String?
        
        socketManager.didChangeString = { id, text in
            changedId = id
            changedText = text
        }
        
        let draftResponse = UpdateDraftResponse(
            event: "update-draft:wsHash:pr{1}:us{2}:en:14477",
            data: UpdateDraftResponseData(text: "Direct Int Text", pluralForm: "none")
        )
        
        socketManager.updateDraft(draftResponse)
        
        XCTAssertEqual(changedId, 14477)
        XCTAssertEqual(changedText, "Direct Int Text")
    }
    
    func testUpdateDraftWithPluralChange() {
        var changedId: Int?
        var changedText: String?
        
        socketManager.didChangePlural = { id, text in
            changedId = id
            changedText = text
        }
        
        let draftResponse = UpdateDraftResponse(
            event: "update-draft:wsHash:pr{1}:us{2}:en:tr{14477}",
            data: UpdateDraftResponseData(text: "Plural Form Text", pluralForm: "other")
        )
        
        socketManager.updateDraft(draftResponse)
        
        XCTAssertEqual(changedId, 14477)
        XCTAssertEqual(changedText, "Plural Form Text")
    }
    
    func testUpdateTopSuggestionTrFormat() {
        var stringChangedId: Int?
        var stringChangedText: String?
        var pluralChangedId: Int?
        var pluralChangedText: String?
        
        socketManager.didChangeString = { id, text in
            stringChangedId = id
            stringChangedText = text
        }
        socketManager.didChangePlural = { id, text in
            pluralChangedId = id
            pluralChangedText = text
        }
        
        let topSuggestionResponse = TopSuggestionResponse(
            event: "top-suggestion:wsHash:pr{1}:en:tr{14477}",
            data: TopSuggestionResponseData(
                id: "100",
                userID: "2",
                time: "1234567890",
                text: "Top Suggestion Text",
                wordsCount: "3"
            )
        )
        
        socketManager.updateTopSuggestion(topSuggestionResponse)
        
        XCTAssertEqual(stringChangedId, 14477)
        XCTAssertEqual(stringChangedText, "Top Suggestion Text")
        XCTAssertEqual(pluralChangedId, 14477)
        XCTAssertEqual(pluralChangedText, "Top Suggestion Text")
    }
    
    func testUpdateTopSuggestionPlainFormat() {
        var stringChangedId: Int?
        var stringChangedText: String?
        var pluralChangedId: Int?
        var pluralChangedText: String?
        
        socketManager.didChangeString = { id, text in
            stringChangedId = id
            stringChangedText = text
        }
        socketManager.didChangePlural = { id, text in
            pluralChangedId = id
            pluralChangedText = text
        }
        
        let topSuggestionResponse = TopSuggestionResponse(
            event: "top-suggestion:wsHash:pr{1}:en:14477",
            data: TopSuggestionResponseData(
                id: "100",
                userID: "2",
                time: "1234567890",
                text: "Plain Top Suggestion Text",
                wordsCount: "4"
            )
        )
        
        socketManager.updateTopSuggestion(topSuggestionResponse)
        
        XCTAssertEqual(stringChangedId, 14477)
        XCTAssertEqual(stringChangedText, "Plain Top Suggestion Text")
        XCTAssertEqual(pluralChangedId, 14477)
        XCTAssertEqual(pluralChangedText, "Plain Top Suggestion Text")
    }
}
