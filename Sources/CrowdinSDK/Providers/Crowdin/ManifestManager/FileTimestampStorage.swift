import Foundation

class FileTimestampStorage {
    private let hash: String
    private var fileTimestamps: [String: [String: TimeInterval]]
    private var storagePath: String {
        return CrowdinFolder.shared.path + "/FileTimestamps/" + hash + ".json"
    }

    init(hash: String) {
        self.hash = hash
        self.fileTimestamps = [:]
        loadTimestamps()
    }

    private func loadTimestamps() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: storagePath)) else { return }
        guard let timestamps = try? JSONDecoder().decode([String: [String: TimeInterval]].self, from: data) else { return }
        self.fileTimestamps = timestamps
    }

    func saveTimestamps() {
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: CrowdinFolder.shared.path + "/FileTimestamps/"), withIntermediateDirectories: true, attributes: nil)
        guard let data = try? JSONEncoder().encode(fileTimestamps) else { return }
        try? data.write(to: URL(fileURLWithPath: storagePath))
    }

    func updateTimestamp(for localization: String, filePath: String, timestamp: TimeInterval) {
        if fileTimestamps[localization] == nil {
            fileTimestamps[localization] = [:]
        }
        fileTimestamps[localization]?[filePath] = timestamp
    }

    func timestamp(for localization: String, filePath: String) -> TimeInterval? {
        return fileTimestamps[localization]?[filePath]
    }
    
    func clear() {
        try? FileManager.default.removeItem(atPath: storagePath)
    }
    
    static func clear() {
        try? FileManager.default.removeItem(atPath: CrowdinFolder.shared.path + "/FileTimestamps/")
    }
}
