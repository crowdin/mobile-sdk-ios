//
//  LocalizationExtractorTests.swift
//  TestsTests
//
//  Created by Serhii Londar on 20.10.2019.
//  Copyright © 2019 Serhii Londar. All rights reserved.
//

import XCTest
@testable import CrowdinSDK

class LocalizationExtractorTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInBundleLocalizations() {
        XCTAssert(LocalLocalizationExtractor.allLocalizations.count == 3)
        XCTAssert(LocalLocalizationExtractor.allLocalizations.contains("en"))
        XCTAssert(LocalLocalizationExtractor.allLocalizations.contains("de"))
        XCTAssert(LocalLocalizationExtractor.allLocalizations.contains("uk"))
    }

    func testExtractDefaultLocalization() {
        let extractor = LocalLocalizationExtractor(localization: "en")
        
        XCTAssert(extractor.localization == "en")
        XCTAssert(!extractor.isEmpty)
        XCTAssert(!extractor.allKeys.isEmpty)
        XCTAssert(!extractor.allValues.isEmpty)
        
    }
    
    func testExtractLocalizationJSON() {
        XCTAssert(!LocalLocalizationExtractor.extractLocalizationJSON().isEmpty)
    }
    /* 
    func testExtractLocalizationJSONtoPath() {
        let file = DocumentsFolder.root.file(with: "LocalizationJSON.json")
        
        LocalLocalizationExtractor.extractLocalizationJSONFile(to: file!.path)
        
        let dictFile = DictionaryFile(path: file!.path)
        
        XCTAssertNotNil(file)
        XCTAssert(file!.isCreated)
        
        let extractedLocalization = dictFile.file
        
        XCTAssertNotNil(extractedLocalization)
        XCTAssert(!extractedLocalization!.isEmpty)
    }
    */
}
