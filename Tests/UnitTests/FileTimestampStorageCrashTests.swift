import XCTest
@testable import CrowdinSDK

class FileTimestampStorageCrashTests: XCTestCase {
    
    var storage: FileTimestampStorage!
    let testHash = "crash_test_hash"
    
    override func setUp() {
        super.setUp()
        storage = FileTimestampStorage(hash: testHash)
    }
    
    override func tearDown() {
        storage.clear()
        FileTimestampStorage.clear()
        super.tearDown()
    }
    
    // This test specifically reproduces the NSInvalidArgumentException crash scenario
    // from the second crash log (549519d5630b9d72cb1fcf3816731fe5)
    func testJSONEncodingCrash() {
        let expectation = XCTestExpectation(description: "JSON encoding crash test")
        expectation.expectedFulfillmentCount = 2
        
        // First thread: rapidly update timestamps
        DispatchQueue.global().async {
            for i in 0..<1000 {
                let localization = "loc_\(i % 10)"
                let filePath = "path_\(i % 20)/file.strings"
                let timestamp = TimeInterval(i)
                
                self.storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                
                // Occasionally save to trigger JSON encoding
                if i % 50 == 0 {
                    self.storage.saveTimestamps()
                }
            }
            expectation.fulfill()
        }
        
        // Second thread: continuously save timestamps to trigger JSON encoding
        DispatchQueue.global().async {
            for _ in 0..<100 {
                self.storage.saveTimestamps()
                Thread.sleep(forTimeInterval: 0.005) // Small delay to increase chance of collision
            }
            expectation.fulfill()
        }
        
        // Wait for both operations to complete
        wait(for: [expectation], timeout: 10.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Test completed without JSON encoding crash")
    }
    
    // This test specifically reproduces the dictionary access crash scenario
    // from the first and fourth crash logs
    func testDictionaryAccessCrash() {
        let expectation = XCTestExpectation(description: "Dictionary access crash test")
        expectation.expectedFulfillmentCount = 3
        
        // Thread 1: Add new localizations and file paths
        DispatchQueue.global().async {
            for i in 0..<500 {
                let localization = "new_loc_\(i % 15)"
                let filePath = "new_path_\(i % 30)/file.strings"
                let timestamp = TimeInterval(i)
                
                self.storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
            }
            expectation.fulfill()
        }
        
        // Thread 2: Read timestamps for existing and non-existing paths
        DispatchQueue.global().async {
            for i in 0..<500 {
                let localization = "loc_\(i % 20)" // Some will exist, some won't
                let filePath = "path_\(i % 40)/file.strings" // Some will exist, some won't
                
                // This would crash without thread safety
                _ = self.storage.timestamp(for: localization, filePath: filePath)
            }
            expectation.fulfill()
        }
        
        // Thread 3: Save timestamps repeatedly
        DispatchQueue.global().async {
            for _ in 0..<50 {
                self.storage.saveTimestamps()
                Thread.sleep(forTimeInterval: 0.01)
            }
            expectation.fulfill()
        }
        
        // Wait for all operations to complete
        wait(for: [expectation], timeout: 10.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Test completed without dictionary access crash")
    }
    
    // This test specifically reproduces the Swift dictionary casting failure
    // from the third crash log (0441ecb3099c7c435a30e46dae6a2159)
    func testDictionaryCastingCrash() {
        let expectation = XCTestExpectation(description: "Dictionary casting crash test")
        expectation.expectedFulfillmentCount = 2
        
        // Thread 1: Create a complex nested dictionary structure
        DispatchQueue.global().async {
            for i in 0..<200 {
                let localization = "complex_loc_\(i % 5)"
                
                // Create many different file paths to make a complex dictionary
                for j in 0..<20 {
                    let filePath = "nested/path/level\(j)/file\(i).strings"
                    let timestamp = TimeInterval(i * 1000 + j)
                    
                    self.storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                }
                
                // Occasionally save to disk
                if i % 20 == 0 {
                    self.storage.saveTimestamps()
                }
            }
            expectation.fulfill()
        }
        
        // Thread 2: Continuously read and save, which would trigger the casting issue
        DispatchQueue.global().async {
            for i in 0..<100 {
                // Read some values
                for j in 0..<5 {
                    let localization = "complex_loc_\(j)"
                    let filePath = "nested/path/level\(i % 20)/file\(i % 200).strings"
                    
                    // This would potentially crash during dictionary access
                    _ = self.storage.timestamp(for: localization, filePath: filePath)
                }
                
                // Save timestamps (this would trigger JSON encoding and potential casting issues)
                self.storage.saveTimestamps()
                
                Thread.sleep(forTimeInterval: 0.005)
            }
            expectation.fulfill()
        }
        
        // Wait for both operations to complete
        wait(for: [expectation], timeout: 15.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Test completed without dictionary casting crash")
    }
    
    // This test combines all crash scenarios in one high-stress test
    func testCombinedCrashScenarios() {
        let expectation = XCTestExpectation(description: "Combined crash scenarios test")
        expectation.expectedFulfillmentCount = 4
        
        // Thread 1: Rapid updates to timestamps
        DispatchQueue.global().async {
            for i in 0..<300 {
                let localization = "loc_\(i % 10)"
                let filePath = "path_\(i % 15)/file.strings"
                let timestamp = TimeInterval(i)
                
                self.storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                
                if i % 30 == 0 {
                    self.storage.saveTimestamps()
                }
            }
            expectation.fulfill()
        }
        
        // Thread 2: Complex nested paths
        DispatchQueue.global().async {
            for i in 0..<200 {
                let localization = "nested_loc_\(i % 5)"
                let filePath = "deep/nested/path/level\(i % 10)/file\(i).strings"
                let timestamp = TimeInterval(i * 100)
                
                self.storage.updateTimestamp(for: localization, filePath: filePath, timestamp: timestamp)
                
                if i % 25 == 0 {
                    self.storage.saveTimestamps()
                }
            }
            expectation.fulfill()
        }
        
        // Thread 3: Frequent reads
        DispatchQueue.global().async {
            for i in 0..<250 {
                // Read from both simple and nested paths
                if i % 2 == 0 {
                    let localization = "loc_\(i % 10)"
                    let filePath = "path_\(i % 15)/file.strings"
                    _ = self.storage.timestamp(for: localization, filePath: filePath)
                } else {
                    let localization = "nested_loc_\(i % 5)"
                    let filePath = "deep/nested/path/level\(i % 10)/file\(i % 200).strings"
                    _ = self.storage.timestamp(for: localization, filePath: filePath)
                }
            }
            expectation.fulfill()
        }
        
        // Thread 4: Frequent saves
        DispatchQueue.global().async {
            for _ in 0..<50 {
                self.storage.saveTimestamps()
                Thread.sleep(forTimeInterval: 0.01)
            }
            expectation.fulfill()
        }
        
        // Wait for all operations to complete
        wait(for: [expectation], timeout: 20.0)
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true, "Combined crash scenarios test completed without crashing")
    }
}
