// TestLogging.swift
// Utilities to add structured logging and progress tracking in tests.

import Foundation
import XCTest
import Dispatch

final class ConcurrentCounter {
    private let lock = NSLock()
    private var _value: Int = 0
    
    func increment() -> Int {
        lock.lock()
        _value &+= 1
        let v = _value
        lock.unlock()
        return v
    }
    
    var value: Int {
        lock.lock()
        let v = _value
        lock.unlock()
        return v
    }
}

enum TestLog {
    static let logFileURL: URL = {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("CrowdinTests-\(ProcessInfo.processInfo.processIdentifier).log")
    }()
    
    static func nowString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
    
    static func threadId() -> UInt64 {
        var tid: UInt64 = 0
        pthread_threadid_np(nil, &tid)
        return tid
    }
    
    static func qosString() -> String {
        let q = qos_class_self()
        switch q {
        case QOS_CLASS_USER_INTERACTIVE: return "userInteractive"
        case QOS_CLASS_USER_INITIATED: return "userInitiated"
        case QOS_CLASS_DEFAULT: return "default"
        case QOS_CLASS_UTILITY: return "utility"
        case QOS_CLASS_BACKGROUND: return "background"
        case QOS_CLASS_UNSPECIFIED: return "unspecified"
        default: return "unknown(\(q.rawValue))"
        }
    }
    
    static func log(_ message: String, label: String) {
        let formatted = "[TEST][\(nowString())][tid=\(threadId())][qos=\(qosString())][\(label)] \(message)"
        // Try NSLog for system log capture
        NSLog(formatted)
        // Also write to stderr
        fputs(formatted + "\n", stderr)
        fflush(stderr)
        // Also write to file for guaranteed capture
        if let data = (formatted + "\n").data(using: .utf8) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
            if let handle = FileHandle(forWritingAtPath: logFileURL.path) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        }
    }
    
    @discardableResult
    static func fulfill(_ expectation: XCTestExpectation, counter: ConcurrentCounter, label: String, expected: Int) -> Int {
        let c = counter.increment()
        if expected > 0 {
            if c % max(1, expected / 10) == 0 || c == expected {
                log("fulfilled \(c)/\(expected)", label: label)
            }
        } else {
            log("fulfilled count: \(c)", label: label)
        }
        expectation.fulfill()
        return c
    }
    
    static func startProgressTimer(label: String, expected: Int, counter: ConcurrentCounter, intervalSeconds: TimeInterval = 5.0) -> DispatchSourceTimer {
        let queue = DispatchQueue(label: "com.crowdin.tests.progress.\(label)")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + intervalSeconds, repeating: intervalSeconds)
        timer.setEventHandler {
            let c = counter.value
            log("progress \(c)/\(expected)", label: label)
        }
        timer.resume()
        return timer
    }
    
    static func stopTimer(_ timer: DispatchSourceTimer?) {
        timer?.setEventHandler {}
        timer?.cancel()
    }
    
    static func dumpLogFile() {
        guard FileManager.default.fileExists(atPath: logFileURL.path) else { return }
        guard let content = try? String(contentsOf: logFileURL) else { return }
        print("\n=== TEST LOG FILE DUMP ===\n\(content)\n=== END LOG FILE ===\n")
    }
}
