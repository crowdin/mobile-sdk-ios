import XCTest
@testable import CrowdinSDK

class FileTimestampStorageTests: XCTestCase {
    
    var storage: FileTimestampStorage!
    let testHash = "test_hash"
    
    override func setUp() {
        super.setUp()
        // Create a new storage instance for each test
        storage = FileTimestampStorage(hash: testHash)
    }
    
    override func tearDown() {
        // Clean up after each test
        storage.clear()
        super.tearDown()
    }
    
    // Test basic functionality
    func testBasicFunctionality() {
        let localization = "en"
        let filePath = "test/path.strings"
        let timestamp: TimeInterval = 12345.67
        
        storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
        let retrievedTimestamp = storage.timestamp(for: localization, filePath: filePath)
        
        XCTAssertEqual(retrievedTimestamp, timestamp, "Retrieved timestamp should match the stored one")
    }
    
    // Test that simulates the specific crash scenario from the logs
    func testDictionaryModificationDuringIteration() {
        let expectation = XCTestExpectation(description: "Concurrent dictionary operations")
        expectation.expectedFulfillmentCount = 2
        
        // Create two concurrent operations that modify and read the dictionary
        DispatchQueue.global().async {
            // Operation 1: Update multiple timestamps rapidly
            for i in 0..<50 {
                self.storage.updateTimestamp(for: "en", filePath: "file\(i).strings", timestamp: TimeInterval(i))
                
                // Introduce a small delay to increase chance of collision
                if i % 10 == 0 {
                    Thread.sleep(forTimeInterval: 0.001)
                }
            }
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            // Operation 2: Save timestamps repeatedly (this triggered the JSON encoding crash)
            for _ in 0..<20 {
                self.storage.saveTimestamps()
                Thread.sleep(forTimeInterval: 0.002)
            }
            expectation.fulfill()
        }
        
        // Wait for both operations to complete
        wait(for: [expectation], timeout: 10.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Test completed without crashing")
    }
    
    // Test that simulates multiple download operations updating timestamps simultaneously
    func testMultipleDownloadOperations() {
        let expectation = XCTestExpectation(description: "Simulated download operations")
        expectation.expectedFulfillmentCount = 4
        
        // Simulate 4 download operations (strings, plurals, xliffs, xcstrings)
        DispatchQueue.global().async {
            // Strings download
            for i in 0..<30 {
                self.storage.updateTimestamp(for: "en", filePath: "strings\(i).strings", timestamp: TimeInterval(i))
                self.storage.saveTimestamps()
            }
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            // Plurals download
            for i in 0..<25 {
                self.storage.updateTimestamp(for: "fr", filePath: "plurals\(i).stringsdict", timestamp: TimeInterval(100 + i))
                self.storage.saveTimestamps()
            }
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            // Xliff download
            for i in 0..<20 {
                self.storage.updateTimestamp(for: "de", filePath: "xliff\(i).xliff", timestamp: TimeInterval(200 + i))
                self.storage.saveTimestamps()
            }
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            // Xcstrings download
            for i in 0..<15 {
                self.storage.updateTimestamp(for: "es", filePath: "strings\(i).xcstrings", timestamp: TimeInterval(300 + i))
                self.storage.saveTimestamps()
            }
            expectation.fulfill()
        }
        
        // Wait for all operations to complete
        wait(for: [expectation], timeout: 15.0)
        
        // Verify some random entries
        XCTAssertNotNil(storage.timestamp(for: "en", filePath: "strings10.strings"))
        XCTAssertNotNil(storage.timestamp(for: "fr", filePath: "plurals15.stringsdict"))
        XCTAssertNotNil(storage.timestamp(for: "de", filePath: "xliff5.xliff"))
        XCTAssertNotNil(storage.timestamp(for: "es", filePath: "strings7.xcstrings"))
    }
}
