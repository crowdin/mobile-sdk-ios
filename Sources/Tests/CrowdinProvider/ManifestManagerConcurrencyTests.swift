//
//  ManifestManagerConcurrencyTests.swift
//  CrowdinSDK-Unit-CrowdinProvider_Tests
//
//  Tests for ManifestManager thread safety, concurrent download deduplication,
//  and race conditions on manifest state transitions.
//

import XCTest
@testable import CrowdinSDK

class ManifestManagerConcurrencyTests: IntegrationTestCase {
    let testHash = "5290b1cfa1eb44bf2581e78106i"
    let sourceLanguage = "en"
    
    override func setUp() {
        super.setUp()
        // Clean up before each test
        ManifestManager.clear()
    }
    
    override func tearDown() {
        ManifestManager.clear()
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
        super.tearDown()
    }
    
    // MARK: - Thread-Safe Property Access Tests
    
    func testConcurrentAccessToLanguages() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations
        
        // Concurrently read languages property
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.languages
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentAccessToFiles() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations
        
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.files
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentAccessToAvailable() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations
        
        // Access available property concurrently while manifest might be downloading
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.available
                expectation.fulfill()
            }
        }
        
        // Start download concurrently
        manifest.download { }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentAccessToTimestamp() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations
        
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.timestamp
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentAccessToHasFileChanged() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations
        
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.hasFileChanged(filePath: "test.strings", localization: "en")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Concurrent Download Deduplication Tests
    
    func testConcurrentDownloadCallsAreDeduplicated() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0 // Allow immediate re-download
        )
        
        // Clear any cached data to force network call
        manifest.clear()
        
        let concurrentCalls = 10
        let expectation = XCTestExpectation(description: "All download completions called")
        expectation.expectedFulfillmentCount = concurrentCalls
        
        var completionTimes: [Date] = []
        let timesQueue = DispatchQueue(label: "test.completion.times")
        
        // Make multiple concurrent download calls
        for _ in 0..<concurrentCalls {
            DispatchQueue.global().async {
                manifest.download {
                    timesQueue.sync {
                        completionTimes.append(Date())
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        // All completions should be called
        XCTAssertEqual(completionTimes.count, concurrentCalls)
        
        // All completions should happen around the same time (within 1 second)
        // This proves they were deduplicated into a single download
        if let first = completionTimes.first, let last = completionTimes.last {
            let timeDifference = last.timeIntervalSince(first)
            XCTAssertLessThan(timeDifference, 1.0, "All completions should be called near-simultaneously")
        }
        
        // Verify manifest data was actually loaded
        XCTAssertTrue(manifest.available)
        XCTAssertNotNil(manifest.languages)
    }
    
    func testDownloadCompletesOnlyOnce() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let firstExpectation = XCTestExpectation(description: "First download")
        let secondExpectation = XCTestExpectation(description: "Second download")
        
        var firstCompleted = false
        var secondCompleted = false
        
        // Start first download
        manifest.download {
            firstCompleted = true
            firstExpectation.fulfill()
        }
        
        // Immediately start second download (should be deduplicated)
        manifest.download {
            secondCompleted = true
            secondExpectation.fulfill()
        }
        
        wait(for: [firstExpectation, secondExpectation], timeout: 60.0)
        
        XCTAssertTrue(firstCompleted)
        XCTAssertTrue(secondCompleted)
        XCTAssertTrue(manifest.available)
    }
    
    func testMinimumIntervalPreventsConcurrentDownloads() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 3600 // 1 hour
        )
        
        let firstExpectation = XCTestExpectation(description: "First download")
        manifest.download {
            firstExpectation.fulfill()
        }
        wait(for: [firstExpectation], timeout: 60.0)
        
        // Second download should complete immediately without network call
        let secondExpectation = XCTestExpectation(description: "Second download skipped")
        let startTime = Date()
        manifest.download {
            let elapsed = Date().timeIntervalSince(startTime)
            // Should complete almost immediately (< 0.1 seconds)
            XCTAssertLessThan(elapsed, 0.1)
            secondExpectation.fulfill()
        }
        
        wait(for: [secondExpectation], timeout: 1.0)
    }
    
    // MARK: - State Transition Race Condition Tests
    
    func testConcurrentReadsAndWritesToState() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent operations completed")
        expectation.expectedFulfillmentCount = iterations * 2 // reads + download initiations
        
        // Concurrently check available status while downloading
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.available
                expectation.fulfill()
            }
        }
        
        // Start downloads concurrently
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                manifest.download {
                    // Download completed
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        // Final state should be valid
        XCTAssertTrue(manifest.available)
    }
    
    // MARK: - iOSLanguages Resolution Tests
    
    func testIOSLanguagesConcurrentAccess() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent iOS languages access")
        expectation.expectedFulfillmentCount = iterations
        
        var results: [[String]] = []
        let resultsQueue = DispatchQueue(label: "test.results")
        
        // Concurrently access iOSLanguages
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                let languages = manifest.iOSLanguages
                resultsQueue.sync {
                    results.append(languages)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // All results should be consistent
        XCTAssertEqual(results.count, iterations)
        if let firstResult = results.first {
            for result in results {
                XCTAssertEqual(result, firstResult, "All concurrent reads should return same result")
            }
        }
    }
    
    func testContentFilesForLanguageConcurrentAccess() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 15 * 60
        )
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent content files access")
        expectation.expectedFulfillmentCount = iterations
        
        var results: [[String]] = []
        let resultsQueue = DispatchQueue(label: "test.results")
        
        // Concurrently access contentFiles
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                let files = manifest.contentFiles(for: "en")
                resultsQueue.sync {
                    results.append(files)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // All results should be consistent
        XCTAssertEqual(results.count, iterations)
        if let firstResult = results.first {
            for result in results {
                XCTAssertEqual(result, firstResult, "All concurrent reads should return same result")
            }
        }
    }
    
    // MARK: - Mixed Concurrent Operations Tests
    
    func testMixedConcurrentReadsDuringDownload() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let iterations = 50
        let expectation = XCTestExpectation(description: "Mixed operations completed")
        expectation.expectedFulfillmentCount = iterations * 6 // 6 different operations
        
        // Start download
        manifest.download { }
        
        // While downloading, perform various read operations concurrently
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = manifest.languages
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = manifest.files
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = manifest.available
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = manifest.timestamp
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = manifest.iOSLanguages
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = manifest.contentFiles(for: "en")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testStressTestWithRapidDownloadAttempts() {
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let downloadAttempts = 20
        let expectation = XCTestExpectation(description: "All downloads handled")
        expectation.expectedFulfillmentCount = downloadAttempts
        
        // Rapidly initiate downloads from multiple threads
        for i in 0..<downloadAttempts {
            DispatchQueue.global().async {
                manifest.download {
                    expectation.fulfill()
                }
            }
            
            // Small delay to stagger the calls slightly
            Thread.sleep(forTimeInterval: 0.01 * Double(i % 3))
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        // Verify final state is consistent
        XCTAssertTrue(manifest.available)
        XCTAssertNotNil(manifest.manifest)
    }
}
