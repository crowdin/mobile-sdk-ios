import Foundation

class FileTimestampStorage {
    private let hash: String
    private var fileTimestamps: [String: [String: TimeInterval]]
    private var storagePath: String {
        return CrowdinFolder.shared.path + "/FileTimestamps/" + hash + ".json"
    }
    
    // Add a lock to protect concurrent access to fileTimestamps
    private let lock = NSLock()

    init(hash: String) {
        self.hash = hash
        self.fileTimestamps = [:]
        loadTimestamps()
    }

    private func loadTimestamps() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: storagePath)) else { return }
        guard let timestamps = try? JSONDecoder().decode([String: [String: TimeInterval]].self, from: data) else { return }
        
        lock.lock()
        defer { lock.unlock() }
        self.fileTimestamps = timestamps
    }

    func saveTimestamps() {
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: CrowdinFolder.shared.path + "/FileTimestamps/"), withIntermediateDirectories: true, attributes: nil)
        
        lock.lock()
        defer { lock.unlock() }
        // Create a copy of fileTimestamps with lock protection
        let timestampsCopy = fileTimestamps
        
        // Encode the copy to avoid modifying the dictionary during encoding
        guard let data = try? JSONEncoder().encode(timestampsCopy) else { return }
        try? data.write(to: URL(fileURLWithPath: storagePath))
    }

    func updateTimestamp(for localization: String, filePath: String, timestamp: TimeInterval?) {
        lock.lock()
        defer { lock.unlock() }
        if fileTimestamps[localization] == nil {
            fileTimestamps[localization] = [:]
        }
        fileTimestamps[localization]?[filePath] = timestamp
    }

    func timestamp(for localization: String, filePath: String) -> TimeInterval? {
        lock.lock()
        defer { lock.unlock() }
        
        return fileTimestamps[localization]?[filePath]
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        try? FileManager.default.removeItem(atPath: storagePath)
        fileTimestamps = [:]
    }
    
    static func clear() {
        try? FileManager.default.removeItem(atPath: CrowdinFolder.shared.path + "/FileTimestamps/")
    }
}
