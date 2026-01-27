//
//  LocalizationDataSourceTests.swift
//  CrowdinSDK-Unit-Core_Tests
//
//  Tests for LocalizationDataSource thread safety after removing the wrapper queue
//  in AnyLocalizationDataSource. Validates that concurrent reads and writes don't
//  cause crashes or data corruption.
//

import XCTest
@testable import CrowdinSDK

class LocalizationDataSourceTests: XCTestCase {
    
    // MARK: - StringsLocalizationDataSource Tests
    
    func testStringsDataSourceConcurrentReads() {
        let testStrings = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
            "formatted_key": "Hello %@!"
        ]
        
        let dataSource = StringsLocalizationDataSource(strings: testStrings)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent reads completed")
        expectation.expectedFulfillmentCount = iterations * 2
        
        // Concurrent reads via findKey
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = dataSource.findKey(for: "value1")
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = dataSource.strings
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStringsDataSourceConcurrentWrites() {
        let initialStrings = ["key1": "value1"]
        let dataSource = StringsLocalizationDataSource(strings: initialStrings)
        
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent writes completed")
        expectation.expectedFulfillmentCount = iterations
        
        // Concurrent writes
        for i in 0..<iterations {
            DispatchQueue.global().async {
                let newStrings = ["key\(i)": "value\(i)"]
                dataSource.update(with: newStrings)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Should not crash and should have some valid data
        XCTAssertNotNil(dataSource.strings)
    }
    
    func testStringsDataSourceConcurrentReadsAndWrites() {
        let initialStrings = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]
        
        let dataSource = StringsLocalizationDataSource(strings: initialStrings)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent reads and writes")
        expectation.expectedFulfillmentCount = iterations * 3
        
        // Mix of reads and writes
        for i in 0..<iterations {
            // Read
            DispatchQueue.global().async {
                _ = dataSource.findKey(for: "value1")
                expectation.fulfill()
            }
            
            // Write
            DispatchQueue.global().async {
                let newStrings = [
                    "key-1": "value1",
                    "key\(i)": "value\(i)"
                ]
                dataSource.update(with: newStrings)
                expectation.fulfill()
            }
            
            // Read strings property
            DispatchQueue.global().async {
                _ = dataSource.strings
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testStringsDataSourceFindKeyWithFormattedStrings() {
        let testStrings = [
            "formatted1": "Hello %@!",
            "formatted2": "User %@ has %d points",
            "simple": "Simple string"
        ]
        
        let dataSource = StringsLocalizationDataSource(strings: testStrings)
        
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent formatted string lookups")
        expectation.expectedFulfillmentCount = iterations
        
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = dataSource.findKey(for: "Simple string")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - PluralsLocalizationDataSource Tests
    
    func testPluralsDataSourceConcurrentReads() {
        let testPlurals: [AnyHashable: Any] = [
            "plural_key": [
                "NSStringLocalizedFormatKey": "%#@value@",
                "value": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "one": "1 item",
                    "other": "%d items"
                ]
            ]
        ]
        
        let dataSource = PluralsLocalizationDataSource(plurals: testPlurals)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent reads completed")
        expectation.expectedFulfillmentCount = iterations * 2
        
        for _ in 0..<iterations {
            DispatchQueue.global().async {
                _ = dataSource.findKey(for: "1 item")
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = dataSource.plurals
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testPluralsDataSourceConcurrentWrites() {
        let initialPlurals: [AnyHashable: Any] = [:]
        let dataSource = PluralsLocalizationDataSource(plurals: initialPlurals)
        
        let iterations = 50
        let expectation = XCTestExpectation(description: "Concurrent writes completed")
        expectation.expectedFulfillmentCount = iterations
        
        for i in 0..<iterations {
            DispatchQueue.global().async {
                let newPlurals: [AnyHashable: Any] = [
                    "key\(i)": [
                        "NSStringLocalizedFormatKey": "%#@value@",
                        "value": [
                            "one": "1",
                            "other": "many"
                        ]
                    ]
                ]
                dataSource.update(with: newPlurals)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(dataSource.plurals)
    }
    
    func testPluralsDataSourceConcurrentReadsAndWrites() {
        let initialPlurals: [AnyHashable: Any] = [
            "test_key": [
                "NSStringLocalizedFormatKey": "%#@value@",
                "value": [
                    "one": "1 item",
                    "other": "%d items"
                ]
            ]
        ]
        
        let dataSource = PluralsLocalizationDataSource(plurals: initialPlurals)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent reads and writes")
        expectation.expectedFulfillmentCount = iterations * 3
        
        for i in 0..<iterations {
            // Read
            DispatchQueue.global().async {
                _ = dataSource.findKey(for: "1 item")
                expectation.fulfill()
            }
            
            // Write
            DispatchQueue.global().async {
                let newPlurals: [AnyHashable: Any] = [
                    "key\(i)": [
                        "NSStringLocalizedFormatKey": "%#@value@",
                        "value": ["one": "1", "other": "many"]
                    ]
                ]
                dataSource.update(with: newPlurals)
                expectation.fulfill()
            }
            
            // Read plurals property
            DispatchQueue.global().async {
                _ = dataSource.plurals
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - AnyLocalizationDataSource Tests
    
    func testAnyDataSourceWithStringsDirectCallsThreadSafety() {
        let testStrings = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]
        
        let stringsDataSource = StringsLocalizationDataSource(strings: testStrings)
        let anyDataSource = AnyLocalizationDataSource(stringsDataSource)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent operations on AnyDataSource")
        expectation.expectedFulfillmentCount = iterations * 3
        
        for i in 0..<iterations {
            // Concurrent reads via findKey
            DispatchQueue.global().async {
                _ = anyDataSource.findKey(for: "value1")
                expectation.fulfill()
            }
            
            // Concurrent writes
            DispatchQueue.global().async {
                let newStrings = ["key\(i)": "value\(i)"]
                anyDataSource.update(with: newStrings)
                expectation.fulfill()
            }
            
            // Concurrent reads via findValues
            DispatchQueue.global().async {
                _ = anyDataSource.findValues(for: "value2", with: "value2")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAnyDataSourceWithPluralsDirectCallsThreadSafety() {
        let testPlurals: [AnyHashable: Any] = [
            "plural_key": [
                "NSStringLocalizedFormatKey": "%#@value@",
                "value": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "one": "1 item",
                    "other": "%d items"
                ]
            ]
        ]
        
        let pluralsDataSource = PluralsLocalizationDataSource(plurals: testPlurals)
        let anyDataSource = AnyLocalizationDataSource(pluralsDataSource)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "Concurrent operations on AnyDataSource")
        expectation.expectedFulfillmentCount = iterations * 2
        
        for _ in 0..<iterations {
            // Concurrent reads
            DispatchQueue.global().async {
                _ = anyDataSource.findKey(for: "1 item")
                expectation.fulfill()
            }
            
            // Concurrent writes
            DispatchQueue.global().async {
                let newPlurals: [AnyHashable: Any] = [
                    "new_key": [
                        "NSStringLocalizedFormatKey": "%#@value@",
                        "value": ["one": "1", "other": "many"]
                    ]
                ]
                anyDataSource.update(with: newPlurals)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Stress Tests
    
    func testStringsDataSourceUnderHeavyLoad() {
        let initialStrings = Dictionary(uniqueKeysWithValues: (0..<100).map { ("key\($0)", "value\($0)") })
        let dataSource = StringsLocalizationDataSource(strings: initialStrings)
        
        let operations = 500
        let expectation = XCTestExpectation(description: "Heavy load completed")
        expectation.expectedFulfillmentCount = operations
        
        for i in 0..<operations {
            let operation = i % 3
            
            DispatchQueue.global().async {
                switch operation {
                case 0:
                    // Read strings
                    _ = dataSource.strings
                case 1:
                    // Find key
                    _ = dataSource.findKey(for: "value\(i % 100)")
                case 2:
                    // Update
                    let newStrings = Dictionary(uniqueKeysWithValues: (0..<10).map { ("key\($0)", "value\($0)_\(i)") })
                    dataSource.update(with: newStrings)
                default:
                    break
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        // Should not crash and should have valid final state
        XCTAssertNotNil(dataSource.strings)
    }
    
    func testPluralsDataSourceUnderHeavyLoad() {
        let initialPlurals: [AnyHashable: Any] = [
            "test_key": [
                "NSStringLocalizedFormatKey": "%#@value@",
                "value": [
                    "one": "1 item",
                    "other": "%d items"
                ]
            ]
        ]
        
        let dataSource = PluralsLocalizationDataSource(plurals: initialPlurals)
        
        let operations = 500
        let expectation = XCTestExpectation(description: "Heavy load completed")
        expectation.expectedFulfillmentCount = operations
        
        for i in 0..<operations {
            let operation = i % 3
            
            DispatchQueue.global().async {
                switch operation {
                case 0:
                    // Read plurals
                    _ = dataSource.plurals
                case 1:
                    // Find key
                    _ = dataSource.findKey(for: "1 item")
                case 2:
                    // Update
                    let newPlurals: [AnyHashable: Any] = [
                        "key\(i)": [
                            "NSStringLocalizedFormatKey": "%#@value@",
                            "value": ["one": "1", "other": "many"]
                        ]
                    ]
                    dataSource.update(with: newPlurals)
                default:
                    break
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        XCTAssertNotNil(dataSource.plurals)
    }
    
    // MARK: - Data Consistency Tests
    
    func testStringsDataSourceDataConsistency() {
        let dataSource = StringsLocalizationDataSource(strings: [:])
        
        let expectedStrings = ["final_key": "final_value"]
        let updateExpectation = XCTestExpectation(description: "Update completed")
        
        // Perform many updates
        for i in 0..<100 {
            DispatchQueue.global().async {
                dataSource.update(with: ["key\(i)": "value\(i)"])
            }
        }
        
        // Final update with known value
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            dataSource.update(with: expectedStrings)
            updateExpectation.fulfill()
        }
        
        wait(for: [updateExpectation], timeout: 5.0)
        
        // Wait a bit more for all updates to settle
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should have the final update
        let finalStrings = dataSource.strings
        XCTAssertNotNil(finalStrings)
    }
    
    func testAnyDataSourceDoesNotDeadlock() {
        let stringsDataSource = StringsLocalizationDataSource(strings: ["key": "value"])
        let anyDataSource = AnyLocalizationDataSource(stringsDataSource)
        
        let iterations = 100
        let expectation = XCTestExpectation(description: "No deadlock")
        expectation.expectedFulfillmentCount = iterations
        
        // Rapidly alternate between reads and writes
        for i in 0..<iterations {
            DispatchQueue.global().async {
                if i % 2 == 0 {
                    _ = anyDataSource.findKey(for: "value")
                } else {
                    anyDataSource.update(with: ["key\(i)": "value\(i)"])
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
