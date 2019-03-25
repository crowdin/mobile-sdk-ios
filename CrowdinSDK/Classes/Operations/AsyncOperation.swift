//
//  AsyncOperation.swift
//  BaseAPIPackageDescription
//
//  Created by Serhii Londar on 5/19/18.
//
import Foundation

protocol AnyAsyncOperation {
    var failed: Bool { get }
    var state: AsyncOperation.State { get }
    func finish(with fail: Bool)
}

public class AsyncOperation: Operation, AnyAsyncOperation {
    public var failed: Bool = false
    public enum State: String {
        case ready, executing, finished
        fileprivate var keyPath: String {
            return "is" + self.rawValue.capitalized
        }
    }
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    public override var isReady: Bool {
        return super.isReady && state == .ready
    }
    public override var isExecuting: Bool {
        return state == .executing
    }
    public override var isFinished: Bool {
        return state == .finished
    }
    public override var isAsynchronous: Bool {
        return true
    }
    public override func start() {
        if isCancelled { state = .finished; return }
        guard !hasCancelledDependencies else{ cancel(); return }
        state = .executing
        main()
    }
    public override func main() {
        fatalError("Should be overriden in child class")
    }
    public override func cancel() {
        state = .finished
    }
    public func finish(with fail: Bool) {
        self.failed = fail
        state = .finished
    }
}

private extension AsyncOperation {
    var hasCancelledDependencies: Bool{
        return dependencies.reduce(false){ $0 || $1.isCancelled }
    }
}
