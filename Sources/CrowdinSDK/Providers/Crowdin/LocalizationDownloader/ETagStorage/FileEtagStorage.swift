//
//  FileEtagStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.05.2022.
//

import Foundation

final class FileEtagStorage: AnyEtagStorage {
    private static let fileName = "Etags.json"
    let localization: String
    let dictionaryFile: DictionaryFile

    var etags: [String: [String: String]] {
        get {
            (dictionaryFile.file as? [String: [String: String]]) ?? [String: [String: String]]()
        }
        set {
            dictionaryFile.file = newValue
            try? dictionaryFile.save()
        }
    }

    init(localization: String) {
        self.localization = localization
        dictionaryFile = DictionaryFile(path: CrowdinFolder.shared.path + "/" + FileEtagStorage.fileName)
        if !dictionaryFile.isCreated {
            dictionaryFile.create()
        }
    }

    func save(etag: String?, for file: String) {
        var localizationEtags = etags[localization] ?? [:]
        localizationEtags[file] = etag
        etags[localization] = localizationEtags
    }

    func etag(for file: String) -> String? {
        etags[localization]?[file]
    }

    func clear() {
        etags[localization] = nil
    }

    func clear(for file: String) {
        var localizationEtags = etags[localization] ?? [:]
        localizationEtags[file] = nil
        etags[localization] = localizationEtags
    }

    /// Remove file
    static func clear() {
        try? DictionaryFile(path: CrowdinFolder.shared.path + "/" + FileEtagStorage.fileName).remove()
    }
}
