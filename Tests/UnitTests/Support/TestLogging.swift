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
    static let logFileURL: URL? = {
        // Try multiple log locations
        var paths: [URL] = [
            FileManager.default.temporaryDirectory.appendingPathComponent("CrowdinTests-\(ProcessInfo.processInfo.processIdentifier).log"),
            URL(fileURLWithPath: "/tmp/CrowdinTests-\(ProcessInfo.processInfo.processIdentifier).log")
        ]
        
        // Add home directory path only on macOS
        #if os(macOS)
        paths.insert(
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".crowdin_test_logs.txt"),
            at: 1
        )
        #endif
        
        for path in paths {
            let dirURL = path.deletingLastPathComponent()
            do {
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
                // Try to write a test byte
                try "".write(to: path, atomically: true, encoding: .utf8)
                return path
            } catch {
                continue
            }
        }
        return nil
    }()

    static func resetLogFile() {
        guard let fileURL = logFileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }
    
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
        
        // 1. Use NSLog (some gets through xcbeautify)
        NSLog("%@", formatted)
        
        // 2. Write directly to stdout (bypasses some filtering)
        print(formatted)
        fflush(stdout)
        
        // 3. Write to stderr
        fputs(formatted + "\n", stderr)
        fflush(stderr)
        
        // 4. Write to file for XCTAttachment
        if let fileURL = logFileURL {
            if let data = (formatted + "\n").data(using: .utf8) {
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil)
                }
                if let handle = FileHandle(forWritingAtPath: fileURL.path) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            }
        }
    }
    
    static func logActivity(_ name: String, block: () -> Void) {
        XCTContext.runActivity(named: name) { _ in
            log("ACTIVITY START: \(name)", label: "Activity")
            block()
            log("ACTIVITY END: \(name)", label: "Activity")
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
    
    static func logFileContent() -> String? {
        guard let fileURL = logFileURL, FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try? String(contentsOf: fileURL)
    }

    static func attachLogFile(to testCase: XCTestCase, name: String = "CrowdinThreadingLog") {
        guard let content = logFileContent() else { return }
        let attachment = XCTAttachment(string: content)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }

    static func dumpLogFile() {
        // Dump to stderr so CI captures it
        fputs("\n=== TEST LOG FILE DUMP ===\n", stderr)
        if let content = logFileContent() {
            fputs(content, stderr)
        }
        fputs("\n=== END LOG FILE ===\n", stderr)
        fflush(stderr)
        // Also try to print to stdout
        if let content = logFileContent() {
            print("\n=== TEST LOG FILE DUMP ===\n\(content)\n=== END LOG FILE ===\n")
        }
    }
}
