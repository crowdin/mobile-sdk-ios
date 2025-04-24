import XCTest
@testable import CrowdinSDK

class CrowdinLocalizationDownloaderTests: XCTestCase {
    
    var downloader: CrowdinLocalizationDownloader!
    var manifestManager: MockManifestManager!
    
    override func setUp() {
        super.setUp()
        // Create a mock manifest manager
        manifestManager = MockManifestManager()
        // Create a downloader with the mock manifest manager
        downloader = CrowdinLocalizationDownloader(manifestManager: manifestManager)
    }
    
    override func tearDown() {
        // Clean up
        manifestManager.fileTimestampStorage.clear()
        super.tearDown()
    }
    
    // Test concurrent calls to updateTimestamp
    func testConcurrentUpdateTimestamp() {
        let expectation = XCTestExpectation(description: "Concurrent updateTimestamp calls")
        expectation.expectedFulfillmentCount = 100
        
        // Track the latest timestamp for each localization/path combination
        var expectedTimestamps = [String: TimeInterval]()
        let expectedLock = NSLock()
        
        // Perform 100 concurrent updateTimestamp calls
        for i in 0..<100 {
            DispatchQueue.global().async {
                let localization = "loc_\(i % 5)"
                let filePath = "path_\(i % 10)/file.strings"
                let timestamp = TimeInterval(i)
                let key = "\(localization)|\(filePath)"
                
                // This method should be thread-safe now
                self.downloader.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                
                // Track the latest timestamp for this combination
                expectedLock.lock()
                expectedTimestamps[key] = timestamp
                expectedLock.unlock()
                
                expectation.fulfill()
            }
        }
        
        // Wait for all operations to complete
        wait(for: [expectation], timeout: 10.0)
        
        // Verify that the timestamps were saved correctly
        for (key, expectedTimestamp) in expectedTimestamps {
            let components = key.split(separator: "|")
            let localization = String(components[0])
            let filePath = String(components[1])
            
            let retrievedTimestamp = manifestManager.fileTimestampStorage.timestamp(for: localization, filePath: filePath)
            XCTAssertEqual(retrievedTimestamp, expectedTimestamp, "Retrieved timestamp should match for \(localization) and \(filePath)")
        }
    }
    
    // Test that simulates multiple download operations running concurrently
    func testSimulatedConcurrentDownloads() {
        // This test simulates the scenario where multiple download operations are running concurrently
        // and calling updateTimestamp, which was causing crashes
        
        let expectation = XCTestExpectation(description: "Simulated concurrent downloads")
        expectation.expectedFulfillmentCount = 4
        
        // Simulate strings download
        DispatchQueue.global().async {
            for i in 0..<30 {
                self.downloader.updateTimestamp(for: "en", filePath: "strings\(i).strings", timestamp: TimeInterval(i))
                
                // Small delay to increase chance of thread collisions
                if i % 10 == 0 {
                    Thread.sleep(forTimeInterval: 0.001)
                }
            }
            expectation.fulfill()
        }
        
        // Simulate plurals download
        DispatchQueue.global().async {
            for i in 0..<25 {
                self.downloader.updateTimestamp(for: "fr", filePath: "plurals\(i).stringsdict", timestamp: TimeInterval(100 + i))
                
                if i % 8 == 0 {
                    Thread.sleep(forTimeInterval: 0.002)
                }
            }
            expectation.fulfill()
        }
        
        // Simulate xliff download
        DispatchQueue.global().async {
            for i in 0..<20 {
                self.downloader.updateTimestamp(for: "de", filePath: "xliff\(i).xliff", timestamp: TimeInterval(200 + i))
                
                if i % 5 == 0 {
                    Thread.sleep(forTimeInterval: 0.001)
                }
            }
            expectation.fulfill()
        }
        
        // Simulate xcstrings download
        DispatchQueue.global().async {
            for i in 0..<15 {
                self.downloader.updateTimestamp(for: "es", filePath: "xcstrings\(i).xcstrings", timestamp: TimeInterval(300 + i))
                
                if i % 7 == 0 {
                    Thread.sleep(forTimeInterval: 0.002)
                }
            }
            expectation.fulfill()
        }
        
        // Wait for all operations to complete
        wait(for: [expectation], timeout: 15.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Test completed without crashing")
        
        // Verify some random entries
        XCTAssertNotNil(manifestManager.fileTimestampStorage.timestamp(for: "en", filePath: "strings10.strings"))
        XCTAssertNotNil(manifestManager.fileTimestampStorage.timestamp(for: "fr", filePath: "plurals15.stringsdict"))
        XCTAssertNotNil(manifestManager.fileTimestampStorage.timestamp(for: "de", filePath: "xliff5.xliff"))
        XCTAssertNotNil(manifestManager.fileTimestampStorage.timestamp(for: "es", filePath: "xcstrings7.xcstrings"))
    }
}

// Mock ManifestManager for testing
class MockManifestManager {
    var hash: String = "test_hash"
    var timestamp: TimeInterval = 12345.67
    var languages: [String] = ["en", "fr", "de", "es"]
    var iOSLanguages: [String] = ["en", "fr", "de", "es"]
    var xcstringsLanguage: String = "en"
    var fileTimestampStorage: FileTimestampStorage
    
    init() {
        self.fileTimestampStorage = FileTimestampStorage(hash: hash)
    }
    
    func download(completion: @escaping () -> Void) {
        // Mock implementation
        completion()
    }
    
    func contentFiles(for language: String) -> [String] {
        // Mock implementation
        return ["file1.strings", "file2.stringsdict", "file3.xliff", "file4.xcstrings"]
    }
    
    func hasFileChanged(filePath: String, localization: String) -> Bool {
        // Mock implementation
        return true
    }
    
    func clear() {
        // Mock implementation
        fileTimestampStorage.clear()
    }
}
