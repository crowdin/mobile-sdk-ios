//
//  CustomBundle.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/12/19.
//

import Foundation

protocol BundleProtocol {
    var bundle: Bundle? { get }
}

protocol FolderBundleProtocol: BundleProtocol {
    var folder: FolderProtocol { get }
}

class FolderBundle: FolderBundleProtocol {
    var bundle: Bundle?
    var folder: FolderProtocol

    init(folder: FolderProtocol) {
        self.folder = folder
        self.bundle = Bundle(path: folder.path)
    }

    init(path: String) {
        self.folder = Folder(path: path)
        do {
            try self.folder.create()
        } catch {
            print(error.localizedDescription)
        }
        self.bundle = Bundle(path: folder.path)
    }
}

protocol FileBundleProtocol: BundleProtocol {
    var file: File { get }
}

class FileBundle: FolderBundle, FileBundleProtocol {
    enum Strings: String {
        case pathDelimiter = "/"
    }

    var file: File

    init(path: String, fileName: String) {
        let folder = Folder(path: path)
        self.file = File(path: folder.path + Strings.pathDelimiter.rawValue + fileName)
        super.init(path: path)
    }
}

protocol DictionaryBundleProtocol: BundleProtocol {
	var dictionary: Dictionary<AnyHashable, Any> { get }
    var file: DictionaryFile { get }
    func remove()
}

class DictionaryBundle: FolderBundle, DictionaryBundleProtocol {
    enum Strings: String {
        case pathDelimiter = "/"
    }

	var dictionary: Dictionary<AnyHashable, Any>
    var file: DictionaryFile

    init(path: String, fileName: String, dictionary: [AnyHashable: Any]) {
        self.dictionary = dictionary
        let folder = Folder(path: path)
        self.file = DictionaryFile(path: folder.path + Strings.pathDelimiter.rawValue + fileName)
        self.file.file = self.dictionary
        try? self.file.save()
        super.init(path: path)
    }

    func remove() {
		try? self.folder.remove()
        try? self.file.remove()
    }
}
