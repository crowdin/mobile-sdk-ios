//
//  CrowdinSupportedLanguagesThreadSafetyTests.swift
//  Tests
//
//  Tests to expose data race in CrowdinSupportedLanguages when
//  supportedLanguages property is accessed concurrently from multiple threads.
//

import XCTest
@testable import CrowdinSDK

class CrowdinSupportedLanguagesThreadSafetyTests: IntegrationTestCase {
    
    override func setUp() {
        super.setUp()
        CrowdinSDK.deintegrate()
    }
    
    override func tearDown() {
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
        ManifestManager.clear()
        super.tearDown()
    }
    
    // MARK: - Data Race Tests
    
    func testConcurrentReadWriteToSupportedLanguages() {
        // This test exposes the data race where supportedLanguages is written
        // from network callback thread and read from other threads simultaneously
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        let supportedLanguages = manifest.crowdinSupportedLanguages
        
        let iterations = 10
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = iterations * 2
        
        // Simulate concurrent reads while download is happening
        for _ in 0..<iterations {
            // Read from one thread
            DispatchQueue.global(qos: .userInitiated).async {
                // This read can race with the write happening in downloadSupportedLanguages callback
                _ = supportedLanguages.supportedLanguages?.data.count
                expectation.fulfill()
            }
            
            // Trigger download from another thread which will write to supportedLanguages
            DispatchQueue.global(qos: .background).async {
                supportedLanguages.downloadSupportedLanguages(completion: {
                    expectation.fulfill()
                }, error: { _ in
                    expectation.fulfill()
                })
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testManifestManagerLanguageResolutionDataRace() {
        // This test specifically reproduces the scenario from the PR comment:
        // ManifestManager reading crowdinSupportedLanguages.supportedLanguages
        // while it's being updated from network callback
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        // Clear cached data to force network download
        manifest.clear()
        
        let downloadExpectation = XCTestExpectation(description: "Manifest downloaded")
        manifest.download {
            downloadExpectation.fulfill()
        }
        
        let iterations = 30
        let accessExpectation = XCTestExpectation(description: "Concurrent access")
        accessExpectation.expectedFulfillmentCount = iterations * 3
        
        // While manifest is downloading (which triggers supportedLanguages download),
        // concurrently access properties that read supportedLanguages
        for _ in 0..<iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                // This calls iOSLanguages which reads crowdinSupportedLanguages.supportedLanguages
                _ = manifest.iOSLanguages
                accessExpectation.fulfill()
            }
            
            DispatchQueue.global(qos: .default).async {
                // This also reads supportedLanguages through crowdinSupportedLanguage(for:)
                _ = manifest.crowdinSupportedLanguage(for: "en")
                accessExpectation.fulfill()
            }
            
            DispatchQueue.global(qos: .background).async {
                // This also accesses supportedLanguages
                _ = manifest.iOSLanguageCode(for: "en")
                accessExpectation.fulfill()
            }
        }
        
        wait(for: [downloadExpectation, accessExpectation], timeout: 60.0)
    }
    
    func testRapidConcurrentAccessToSupportedLanguagesProperty() {
        // This test hammers the supportedLanguages property with concurrent reads and writes
        // to maximize the chance of exposing the race condition
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        let supportedLanguages = manifest.crowdinSupportedLanguages
        
        // First, ensure we have some data
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        supportedLanguages.downloadSupportedLanguages(completion: {
            initialLoadExpectation.fulfill()
        })
        wait(for: [initialLoadExpectation], timeout: 60.0)
        
        // Now hammer it with concurrent access
        let iterations = 20
        let expectation = XCTestExpectation(description: "Stress test completed")
        expectation.expectedFulfillmentCount = iterations * 4
        
        for i in 0..<iterations {
            // Multiple read operations from different threads
            DispatchQueue.global(qos: .userInteractive).async {
                _ = supportedLanguages.supportedLanguages?.data.first?.data.id
                expectation.fulfill()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                _ = supportedLanguages.loaded
                expectation.fulfill()
            }
            
            DispatchQueue.global(qos: .default).async {
                _ = supportedLanguages.supportedLanguages?.data.map { $0.data.name }
                expectation.fulfill()
            }
            
            // Periodically trigger downloads which write to supportedLanguages
            if i % 10 == 0 {
                DispatchQueue.global(qos: .background).async {
                    supportedLanguages.downloadSupportedLanguages(completion: {
                        expectation.fulfill()
                    }, error: { _ in
                        expectation.fulfill()
                    })
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    _ = supportedLanguages.supportedLanguages?.data.count
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testContentFilesForLanguageDataRace() {
        // This test specifically targets the contentFiles(for:) method which
        // accesses crowdinSupportedLanguages.supportedLanguages multiple times
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        // Clear and download manifest
        manifest.clear()
        let downloadExpectation = XCTestExpectation(description: "Download completed")
        manifest.download {
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 10
        let expectation = XCTestExpectation(description: "Content files access")
        expectation.expectedFulfillmentCount = iterations * 2
        
        for _ in 0..<iterations {
            // Read contentFiles which internally reads supportedLanguages
            DispatchQueue.global(qos: .userInitiated).async {
                _ = manifest.contentFiles(for: "en")
                expectation.fulfill()
            }
            
            // Concurrently trigger supportedLanguages download
            DispatchQueue.global(qos: .background).async {
                manifest.crowdinSupportedLanguages.downloadSupportedLanguages(completion: {
                    expectation.fulfill()
                })
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testIOSLanguagesComputedPropertyDataRace() {
        // This test focuses on iOSLanguages which has complex logic
        // reading supportedLanguages multiple times
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let iterations = 10
        let expectation = XCTestExpectation(description: "iOSLanguages access")
        expectation.expectedFulfillmentCount = iterations * 2 + 1
        
        // Start manifest download in background
        DispatchQueue.global(qos: .background).async {
            manifest.download {
                expectation.fulfill()
            }
        }
        
        // While downloading, hammer iOSLanguages property
        for _ in 0..<iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                let languages = manifest.iOSLanguages
                // Force use of the result
                _ = languages.count
                expectation.fulfill()
            }
            
            DispatchQueue.global(qos: .default).async {
                // Also access through other methods
                _ = manifest.crowdinSupportedLanguage(for: "en")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testThreadSanitizerDetection() {
        // This test is specifically designed to trigger Thread Sanitizer
        // when run with -sanitize=thread flag
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        let supportedLanguages = manifest.crowdinSupportedLanguages
        
        // Use suspended queues to coordinate start instead of semaphore to avoid priority inversion warnings
        let readerQueue = DispatchQueue(label: "com.crowdin.test.reader", qos: .userInitiated, attributes: .concurrent)
        let writerQueue = DispatchQueue(label: "com.crowdin.test.writer", qos: .background, attributes: .concurrent)
        
        readerQueue.suspend()
        writerQueue.suspend()
        
        let iterations = 10
        let expectation = XCTestExpectation(description: "Thread sanitizer test")
        expectation.expectedFulfillmentCount = iterations * 2
        
        // Start reader threads
        for _ in 0..<iterations {
            readerQueue.async {
                // Read operation
                _ = supportedLanguages.supportedLanguages?.data.map { $0.data }
                expectation.fulfill()
            }
        }
        
        // Start writer threads (via download)
        for _ in 0..<iterations {
            writerQueue.async {
                // Write operation through download
                supportedLanguages.downloadSupportedLanguages(completion: {
                    expectation.fulfill()
                })
            }
        }
        
        // Release all threads simultaneously
        readerQueue.resume()
        writerQueue.resume()
        
        wait(for: [expectation], timeout: 60.0)
    }
}
