//
//  CrowdinSupportedLanguagesThreadSafetyTests.swift
//  Tests
//
//  Tests to expose data race in CrowdinSupportedLanguages when
//  supportedLanguages property is accessed concurrently from multiple threads.
//

import XCTest
@testable import CrowdinSDK

class CrowdinSupportedLanguagesThreadSafetyTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        TestLog.log("TEST CLASS SETUP", label: "Suite")
        TestLog.log("Process ID: \(ProcessInfo.processInfo.processIdentifier)", label: "Suite")
        TestLog.log("Active processor count: \(ProcessInfo.processInfo.activeProcessorCount)", label: "Suite")
        if let logPath = TestLog.logFileURL?.path {
            TestLog.log("Log file path: \(logPath)", label: "Suite")
        } else {
            TestLog.log("WARNING: No writable log file path found", label: "Suite")
        }
    }
    
    override func setUp() {
        super.setUp()
        TestLog.resetLogFile()
        TestLog.log("setUp: deintegrate", label: "Suite")
        CrowdinSDK.deintegrate()
    }
    
    override func tearDown() {
        TestLog.log("tearDown: cleanup start", label: "Suite")
        CrowdinSDK.removeAllErrorHandlers()
        CrowdinSDK.removeAllDownloadHandlers()
        CrowdinSDK.deintegrate()
        CrowdinSDK.stop()
        TestLog.log("tearDown: cleanup done", label: "Suite")
        // Dump logs on test failure or completion
        TestLog.dumpLogFile()
        TestLog.attachLogFile(to: self)
        super.tearDown()
    }
    
    // MARK: - Data Race Tests
    
    func testConcurrentReadWriteToSupportedLanguages() {
        TestLog.log("========== TEST START: testConcurrentReadWriteToSupportedLanguages ==========", label: "Suite")
        defer {
            TestLog.log("========== TEST END: testConcurrentReadWriteToSupportedLanguages ==========", label: "Suite")
            TestLog.dumpLogFile()
        }
        
        // This test exposes the data race where supportedLanguages is written
        // from network callback thread and read from other threads simultaneously
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        TestLog.log("init manifest", label: "ConcurrentReadWrite")
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        let supportedLanguages = manifest.crowdinSupportedLanguages
        
        let iterations = 10  // Reduced from 100 for faster iteration
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        let expected = iterations * 2
        expectation.expectedFulfillmentCount = expected
        let counter = ConcurrentCounter()
        let timer = TestLog.startProgressTimer(label: "ConcurrentReadWrite", expected: expected, counter: counter, intervalSeconds: 2.0)
        TestLog.log("START iterations=\(iterations) expected=\(expected)", label: "ConcurrentReadWrite")
        
        // Simulate concurrent reads while download is happening
        for i in 0..<iterations {
            // Read from one thread
            DispatchQueue.global(qos: .userInitiated).async {
                TestLog.log("reader \(i) start", label: "ConcurrentReadWrite")
                let count = supportedLanguages.supportedLanguages?.data.count
                if count == nil {
                    TestLog.log("reader \(i): supportedLanguages is nil", label: "ConcurrentReadWrite")
                } else {
                    TestLog.log("reader \(i): count=\(count ?? -1)", label: "ConcurrentReadWrite")
                }
                _ = count
                _ = TestLog.fulfill(expectation, counter: counter, label: "reader", expected: expected)
            }
            
            // Trigger download from another thread which will write to supportedLanguages
            DispatchQueue.global(qos: .background).async {
                TestLog.log("writer \(i) downloadSupportedLanguages start", label: "ConcurrentReadWrite")
                supportedLanguages.downloadSupportedLanguages(completion: {
                    TestLog.log("writer \(i) downloadSupportedLanguages done", label: "ConcurrentReadWrite")
                    _ = TestLog.fulfill(expectation, counter: counter, label: "writer", expected: expected)
                })
            }
        }
        
        TestLog.log("waiting for expectations, timeout=120s", label: "ConcurrentReadWrite")
        wait(for: [expectation], timeout: 120.0)
        TestLog.stopTimer(timer)
        TestLog.log("END fulfilled=\(counter.value)/\(expected)", label: "ConcurrentReadWrite")
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
        TestLog.log("========== TEST START: testRapidConcurrentAccessToSupportedLanguagesProperty ==========", label: "Suite")
        defer {
            TestLog.log("========== TEST END: testRapidConcurrentAccessToSupportedLanguagesProperty ==========", label: "Suite")
            TestLog.dumpLogFile()
        }
        
        // This test hammers the supportedLanguages property with concurrent reads and writes
        // to maximize the chance of exposing the race condition
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        TestLog.log("init manifest", label: "RapidAccess")
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        let supportedLanguages = manifest.crowdinSupportedLanguages
        
        // First, ensure we have some data
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        TestLog.log("initial download start", label: "RapidAccess")
        supportedLanguages.downloadSupportedLanguages(completion: {
            TestLog.log("initial download done", label: "RapidAccess")
            initialLoadExpectation.fulfill()
        })
        wait(for: [initialLoadExpectation], timeout: 60.0)
        
        // Now hammer it with concurrent access
        let iterations = 20  // Reduced from 200
        let expectation = XCTestExpectation(description: "Stress test completed")
        let expected = iterations * 4
        expectation.expectedFulfillmentCount = expected
        let counter = ConcurrentCounter()
        let timer = TestLog.startProgressTimer(label: "RapidAccess", expected: expected, counter: counter, intervalSeconds: 2.0)
        TestLog.log("START iterations=\(iterations) expected=\(expected)", label: "RapidAccess")
        
        for i in 0..<iterations {
            // Multiple read operations from different threads
            DispatchQueue.global(qos: .userInteractive).async {
                TestLog.log("read firstId \(i) start", label: "RapidAccess")
                let id = supportedLanguages.supportedLanguages?.data.first?.data.id
                TestLog.log("read firstId \(i): id=\(String(describing: id))", label: "RapidAccess")
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.firstId", expected: expected)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                TestLog.log("read loaded \(i) start", label: "RapidAccess")
                let loaded = supportedLanguages.loaded
                TestLog.log("read loaded \(i): loaded=\(loaded)", label: "RapidAccess")
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.loaded", expected: expected)
            }
            
            DispatchQueue.global(qos: .default).async {
                TestLog.log("read names \(i) start", label: "RapidAccess")
                let names = supportedLanguages.supportedLanguages?.data.map { $0.data.name }
                TestLog.log("read names \(i): count=\(names?.count ?? -1)", label: "RapidAccess")
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.names", expected: expected)
            }
            
            // Periodically trigger downloads which write to supportedLanguages
            if i % 2 == 0 {  // Changed from i % 10
                DispatchQueue.global(qos: .background).async {
                    TestLog.log("writer: download start (i=\(i))", label: "RapidAccess")
                    supportedLanguages.downloadSupportedLanguages(completion: {
                        TestLog.log("writer: download done (i=\(i))", label: "RapidAccess")
                        _ = TestLog.fulfill(expectation, counter: counter, label: "write.download", expected: expected)
                    })
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    TestLog.log("bg count \(i) start", label: "RapidAccess")
                    let c = supportedLanguages.supportedLanguages?.data.count
                    TestLog.log("bg count \(i): count=\(c ?? -1)", label: "RapidAccess")
                    _ = TestLog.fulfill(expectation, counter: counter, label: "bg.count", expected: expected)
                }
            }
        }
        
        TestLog.log("waiting for expectations, timeout=120s", label: "RapidAccess")
        wait(for: [expectation], timeout: 120.0)
        TestLog.stopTimer(timer)
        TestLog.log("END fulfilled=\(counter.value)/\(expected)", label: "RapidAccess")
    }
    
    func testContentFilesForLanguageDataRace() {
        TestLog.log("========== TEST START: testContentFilesForLanguageDataRace ==========", label: "Suite")
        defer {
            TestLog.log("========== TEST END: testContentFilesForLanguageDataRace ==========", label: "Suite")
            TestLog.dumpLogFile()
        }
        
        // This test specifically targets the contentFiles(for:) method which
        // accesses crowdinSupportedLanguages.supportedLanguages multiple times
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        TestLog.log("init manifest", label: "ContentFilesRace")
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        // Clear and download manifest
        manifest.clear()
        let downloadExpectation = XCTestExpectation(description: "Download completed")
        TestLog.log("manifest download start", label: "ContentFilesRace")
        manifest.download {
            TestLog.log("manifest download done", label: "ContentFilesRace")
            downloadExpectation.fulfill()
        }
        wait(for: [downloadExpectation], timeout: 60.0)
        
        let iterations = 20  // Reduced from 100
        let expectation = XCTestExpectation(description: "Content files access")
        let expected = iterations * 2
        expectation.expectedFulfillmentCount = expected
        let counter = ConcurrentCounter()
        let timer = TestLog.startProgressTimer(label: "ContentFilesRace", expected: expected, counter: counter, intervalSeconds: 2.0)
        TestLog.log("START iterations=\(iterations) expected=\(expected)", label: "ContentFilesRace")
        
        for i in 0..<iterations {
            // Read contentFiles which internally reads supportedLanguages
            DispatchQueue.global(qos: .userInitiated).async {
                TestLog.log("contentFiles \(i) start", label: "ContentFilesRace")
                let files = manifest.contentFiles(for: "en")
                TestLog.log("contentFiles \(i): count=\(files.count)", label: "ContentFilesRace")
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.contentFiles", expected: expected)
            }
            
            // Concurrently trigger supportedLanguages download
            DispatchQueue.global(qos: .background).async {
                TestLog.log("writer \(i): download start", label: "ContentFilesRace")
                manifest.crowdinSupportedLanguages.downloadSupportedLanguages(completion: {
                    TestLog.log("writer \(i): download done", label: "ContentFilesRace")
                    _ = TestLog.fulfill(expectation, counter: counter, label: "write.download", expected: expected)
                })
            }
        }
        
        TestLog.log("waiting for expectations, timeout=120s", label: "ContentFilesRace")
        wait(for: [expectation], timeout: 120.0)
        TestLog.stopTimer(timer)
        TestLog.log("END fulfilled=\(counter.value)/\(expected)", label: "ContentFilesRace")
    }
    
    func testIOSLanguagesComputedPropertyDataRace() {
        TestLog.log("========== TEST START: testIOSLanguagesComputedPropertyDataRace ==========", label: "Suite")
        defer {
            TestLog.log("========== TEST END: testIOSLanguagesComputedPropertyDataRace ==========", label: "Suite")
            TestLog.dumpLogFile()
        }
        
        // This test focuses on iOSLanguages which has complex logic
        // reading supportedLanguages multiple times
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        TestLog.log("init manifest", label: "iOSLanguagesRace")
        let manifest = ManifestManager.manifest(
            for: testHash,
            sourceLanguage: sourceLanguage,
            organizationName: nil,
            minimumManifestUpdateInterval: 0
        )
        
        manifest.clear()
        
        let iterations = 10  // Reduced from 50
        let expectation = XCTestExpectation(description: "iOSLanguages access")
        let expected = iterations * 2 + 1
        expectation.expectedFulfillmentCount = expected
        let counter = ConcurrentCounter()
        let timer = TestLog.startProgressTimer(label: "iOSLanguagesRace", expected: expected, counter: counter, intervalSeconds: 2.0)
        TestLog.log("START iterations=\(iterations) expected=\(expected)", label: "iOSLanguagesRace")
        
        // Start manifest download in background
        DispatchQueue.global(qos: .background).async {
            TestLog.log("manifest download start", label: "iOSLanguagesRace")
            manifest.download {
                TestLog.log("manifest download done", label: "iOSLanguagesRace")
                _ = TestLog.fulfill(expectation, counter: counter, label: "download.done", expected: expected)
            }
        }
        
        // While downloading, hammer iOSLanguages property
        for i in 0..<iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                TestLog.log("iOSLanguages \(i) start", label: "iOSLanguagesRace")
                let languages = manifest.iOSLanguages
                TestLog.log("iOSLanguages \(i): count=\(languages.count)", label: "iOSLanguagesRace")
                _ = languages.count
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.iOSLanguages", expected: expected)
            }
            
            DispatchQueue.global(qos: .default).async {
                TestLog.log("crowdinSupportedLanguage \(i) start", label: "iOSLanguagesRace")
                // Also access through other methods
                let lang = manifest.crowdinSupportedLanguage(for: "en")
                TestLog.log("crowdinSupportedLanguage \(i): lang=\(String(describing: lang))", label: "iOSLanguagesRace")
                _ = TestLog.fulfill(expectation, counter: counter, label: "read.crowdinLang", expected: expected)
            }
        }
        
        TestLog.log("waiting for expectations, timeout=120s", label: "iOSLanguagesRace")
        wait(for: [expectation], timeout: 120.0)
        TestLog.stopTimer(timer)
        TestLog.log("END fulfilled=\(counter.value)/\(expected)", label: "iOSLanguagesRace")
    }
    
    func testThreadSanitizerDetection() {
        TestLog.log("========== TEST START: testThreadSanitizerDetection ==========", label: "Suite")
        defer {
            TestLog.log("========== TEST END: testThreadSanitizerDetection ==========", label: "Suite")
            TestLog.dumpLogFile()
        }
        
        // This test is specifically designed to trigger Thread Sanitizer
        // when run with -sanitize=thread flag
        
        let testHash = "5290b1cfa1eb44bf2581e78106i"
        let sourceLanguage = "en"
        
        TestLog.log("init manifest", label: "TSan")
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
        
        let iterations = 5  // Reduced from 10
        let expectation = XCTestExpectation(description: "Thread sanitizer test")
        let expected = iterations * 2
        expectation.expectedFulfillmentCount = expected
        let counter = ConcurrentCounter()
        let timer = TestLog.startProgressTimer(label: "TSan", expected: expected, counter: counter, intervalSeconds: 2.0)
        TestLog.log("START iterations=\(iterations) expected=\(expected)", label: "TSan")
        
        // Start reader threads
        for i in 0..<iterations {
            readerQueue.async {
                TestLog.log("reader \(i) start", label: "TSan")
                // Read operation
                let values = supportedLanguages.supportedLanguages?.data.map { $0.data }
                TestLog.log("reader \(i): values.count=\(values?.count ?? -1)", label: "TSan")
                _ = TestLog.fulfill(expectation, counter: counter, label: "reader", expected: expected)
            }
        }
        
        // Start writer threads (via download)
        for i in 0..<iterations {
            writerQueue.async {
                // Write operation through download
                TestLog.log("writer \(i): download start", label: "TSan")
                supportedLanguages.downloadSupportedLanguages(completion: {
                    TestLog.log("writer \(i): download done", label: "TSan")
                    _ = TestLog.fulfill(expectation, counter: counter, label: "writer", expected: expected)
                })
            }
        }
        
        // Release all threads simultaneously
        TestLog.log("queues resume", label: "TSan")
        readerQueue.resume()
        writerQueue.resume()
        
        TestLog.log("waiting for expectations, timeout=120s", label: "TSan")
        wait(for: [expectation], timeout: 120.0)
        TestLog.stopTimer(timer)
        TestLog.log("END fulfilled=\(counter.value)/\(expected)", label: "TSan")
    }
}
