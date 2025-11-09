//
//  AsyncOperationTests.swift
//  CrowdinSDK-Unit-CrowdinProvider_Tests
//
//  Tests for AsyncOperation state transitions, cancellation handling, and KVO notifications.
//

import XCTest
@testable import CrowdinSDK

class AsyncOperationTests: XCTestCase {
    
    // MARK: - Test Operation Subclass
    
    private class TestAsyncOperation: AsyncOperation {
        var mainCallCount = 0
        var shouldCompleteImmediately = true
        var completionDelay: TimeInterval = 0
        
        override func main() {
            mainCallCount += 1
            
            if shouldCompleteImmediately {
                finish(with: false)
            } else if completionDelay > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + completionDelay) {
                    self.finish(with: false)
                }
            }
        }
    }
    
    // MARK: - State Transition Tests
    
    func testOperationStartsInReadyState() {
        let operation = TestAsyncOperation()
        
        XCTAssertTrue(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertFalse(operation.isFinished)
        XCTAssertEqual(operation.state, .ready)
    }
    
    func testOperationTransitionsToExecutingWhenStarted() {
        let operation = TestAsyncOperation()
        operation.shouldCompleteImmediately = false
        
        let expectation = XCTestExpectation(description: "Operation started")
        
        // Use KVO to observe state change
        let observation = operation.observe(\.isExecuting) { op, _ in
            if op.isExecuting {
                XCTAssertEqual(op.state, .executing)
                XCTAssertFalse(op.isReady)
                XCTAssertFalse(op.isFinished)
                expectation.fulfill()
            }
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        wait(for: [expectation], timeout: 1.0)
        observation.invalidate()
        
        // Clean up
        operation.cancel()
    }
    
    func testOperationTransitionsToFinishedWhenCompleted() {
        let operation = TestAsyncOperation()
        
        let expectation = XCTestExpectation(description: "Operation finished")
        
        let observation = operation.observe(\.isFinished) { op, _ in
            if op.isFinished {
                XCTAssertEqual(op.state, .finished)
                XCTAssertFalse(op.isReady)
                XCTAssertFalse(op.isExecuting)
                XCTAssertEqual(op.mainCallCount, 1)
                expectation.fulfill()
            }
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        wait(for: [expectation], timeout: 1.0)
        observation.invalidate()
    }
    
    // MARK: - Cancellation Tests
    
    func testCancellationBeforeExecution() {
        let operation = TestAsyncOperation()
        operation.shouldCompleteImmediately = false
        
        let expectation = XCTestExpectation(description: "Operation finished after cancel")
        
        // Cancel before adding to queue
        operation.cancel()
        
        XCTAssertTrue(operation.isCancelled)
        XCTAssertTrue(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        
        let observation = operation.observe(\.isFinished) { op, _ in
            if op.isFinished {
                // Operation should finish without calling main()
                XCTAssertEqual(op.mainCallCount, 0)
                XCTAssertTrue(op.isCancelled)
                expectation.fulfill()
            }
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        wait(for: [expectation], timeout: 1.0)
        observation.invalidate()
    }
    
    func testCancellationDuringExecution() {
        let operation = TestAsyncOperation()
        operation.shouldCompleteImmediately = false
        operation.completionDelay = 0.5
        
        let expectation = XCTestExpectation(description: "Operation cancelled during execution")
        
        var wasExecuting = false
        let observation = operation.observe(\.isFinished) { op, _ in
            if op.isFinished {
                XCTAssertTrue(wasExecuting, "Operation should have been executing before cancel")
                XCTAssertTrue(op.isCancelled)
                expectation.fulfill()
            }
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        // Wait a bit for operation to start executing
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            wasExecuting = operation.isExecuting
            operation.cancel()
        }
        
        wait(for: [expectation], timeout: 2.0)
        observation.invalidate()
    }
    
    func testCancellationDoesNotFinishIfNotExecuting() {
        let operation = TestAsyncOperation()
        operation.shouldCompleteImmediately = false
        
        // Cancel before execution
        operation.cancel()
        
        XCTAssertTrue(operation.isCancelled)
        XCTAssertTrue(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        
        // The state should not be finished yet if we haven't started
        // It will transition to finished when the queue processes it
        XCTAssertEqual(operation.state, .ready)
    }
    
    // MARK: - KVO Notification Tests
    
    func testKVONotificationsForStateTransitions() {
        let operation = TestAsyncOperation()
        
        var isReadyChanges = 0
        var isExecutingChanges = 0
        var isFinishedChanges = 0
        
        let readyObservation = operation.observe(\.isReady, options: [.old, .new]) { _, change in
            if change.oldValue != change.newValue {
                isReadyChanges += 1
            }
        }
        
        let executingObservation = operation.observe(\.isExecuting, options: [.old, .new]) { _, change in
            if change.oldValue != change.newValue {
                isExecutingChanges += 1
            }
        }
        
        let finishedObservation = operation.observe(\.isFinished, options: [.old, .new]) { _, change in
            if change.oldValue != change.newValue {
                isFinishedChanges += 1
            }
        }
        
        let expectation = XCTestExpectation(description: "Operation completed")
        operation.completionBlock = {
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Give KVO a moment to settle
        Thread.sleep(forTimeInterval: 0.1)
        
        // Should see transitions: ready->executing, executing->finished
        XCTAssertGreaterThanOrEqual(isReadyChanges, 1, "isReady should change at least once")
        XCTAssertGreaterThanOrEqual(isExecutingChanges, 2, "isExecuting should change at least twice (false->true->false)")
        XCTAssertGreaterThanOrEqual(isFinishedChanges, 1, "isFinished should change at least once")
        
        readyObservation.invalidate()
        executingObservation.invalidate()
        finishedObservation.invalidate()
    }
    
    func testKVONotificationsForCancellationBeforeStart() {
        let operation = TestAsyncOperation()
        operation.shouldCompleteImmediately = false
        
        var isFinishedChanges = 0
        var isExecutingChanges = 0
        
        let finishedObservation = operation.observe(\.isFinished, options: [.old, .new]) { _, change in
            if change.oldValue != change.newValue {
                isFinishedChanges += 1
            }
        }
        
        let executingObservation = operation.observe(\.isExecuting, options: [.old, .new]) { _, change in
            if change.oldValue != change.newValue {
                isExecutingChanges += 1
            }
        }
        
        // Cancel before starting
        operation.cancel()
        
        let expectation = XCTestExpectation(description: "Operation finished")
        operation.completionBlock = {
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Give KVO a moment to settle
        Thread.sleep(forTimeInterval: 0.1)
        
        // Should see proper KVO notifications for the state transitions
        XCTAssertGreaterThanOrEqual(isFinishedChanges, 1, "isFinished should change")
        XCTAssertGreaterThanOrEqual(isExecutingChanges, 2, "isExecuting should transition properly")
        
        finishedObservation.invalidate()
        executingObservation.invalidate()
    }
    
    // MARK: - Failed State Tests
    
    func testOperationCanFinishWithFailure() {
        let expectation = XCTestExpectation(description: "Operation finished with failure")
        
        // Override main to finish with failure
        class FailingOperation: TestAsyncOperation {
            override func main() {
                finish(with: true)
            }
        }
        
        let failingOp = FailingOperation()
        failingOp.completionBlock = {
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.addOperation(failingOp)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(failingOp.failed)
        XCTAssertTrue(failingOp.isFinished)
    }
    
    // MARK: - Dependency Tests
    
    func testOperationWithCancelledDependency() {
        let dependency = TestAsyncOperation()
        dependency.shouldCompleteImmediately = false
        
        let operation = TestAsyncOperation()
        operation.addDependency(dependency)
        
        // Cancel dependency
        dependency.cancel()
        
        let expectation = XCTestExpectation(description: "Both operations finished")
        expectation.expectedFulfillmentCount = 2
        
        dependency.completionBlock = { expectation.fulfill() }
        operation.completionBlock = { expectation.fulfill() }
        
        let queue = OperationQueue()
        queue.addOperations([dependency, operation], waitUntilFinished: false)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Operation should also be cancelled due to cancelled dependency
        XCTAssertTrue(dependency.isCancelled)
        XCTAssertTrue(operation.isCancelled)
    }
    
    // MARK: - Concurrent Execution Tests
    
    func testMultipleOperationsConcurrently() {
        let operations = (0..<10).map { _ in TestAsyncOperation() }
        
        let expectation = XCTestExpectation(description: "All operations finished")
        expectation.expectedFulfillmentCount = 10
        
        operations.forEach { op in
            op.completionBlock = {
                expectation.fulfill()
            }
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        queue.addOperations(operations, waitUntilFinished: false)
        
        wait(for: [expectation], timeout: 5.0)
        
        operations.forEach { op in
            XCTAssertTrue(op.isFinished)
            XCTAssertEqual(op.mainCallCount, 1)
        }
    }
}
