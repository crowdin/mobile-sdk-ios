//
//  FileEtagStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.05.2022.
//

import Foundation

final class FileEtagStorage: AnyEtagStorage {
    private static let fileName = "Etags.json"
    private let queue = DispatchQueue(label: "com.crowdin.FileEtagStorage")
    let localization: String
    private var dictionaryFile: DictionaryFile
    
    private func getEtags() -> [String: [String: String]] {
        dictionaryFile.read()
        return (dictionaryFile.file as? [String: [String: String]]) ?? [:]
    }
    init(localization: String) {
        self.localization = localization
        let path = CrowdinFolder.shared.path + "/" + FileEtagStorage.fileName
        self.dictionaryFile = DictionaryFile(path: path)
        if !dictionaryFile.isCreated {
            dictionaryFile.create()
        }
    }
    func save(etag: String?, for file: String) {
        queue.sync {
            var currentEtags = getEtags()
            var localizationEtags = currentEtags[localization] ?? [:]
            localizationEtags[file] = etag
            currentEtags[localization] = localizationEtags
            dictionaryFile.file = currentEtags
            try? self.dictionaryFile.save()
        }
    }
    func etag(for file: String) -> String? {
        queue.sync {
            let currentEtags = getEtags()
            return currentEtags[localization]?[file]
        }
    }
    func clear() {
        queue.sync {
            var currentEtags = getEtags()
            currentEtags[localization] = nil
            dictionaryFile.file = currentEtags
            try? self.dictionaryFile.save()
        }
    }
    func clear(for file: String) {
        queue.sync {
            var currentEtags = getEtags()
            var localizationEtags = currentEtags[localization] ?? [:]
            localizationEtags[file] = nil
            currentEtags[localization] = localizationEtags
            dictionaryFile.file = currentEtags
            try? self.dictionaryFile.save()
        }
    }
    /// Remove file
    static func clear() {
        let path = CrowdinFolder.shared.path + "/" + FileEtagStorage.fileName
        try? DictionaryFile(path: path).remove()
    }
}
