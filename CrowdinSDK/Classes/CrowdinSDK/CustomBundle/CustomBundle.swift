//
//  CustomBundle.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/12/19.
//

import Foundation

protocol CustomBundleProtocol {
    var bundle: Bundle { get }
    var folder: Folder { get }
}

class CustomBundle: CustomBundleProtocol {
    var bundle: Bundle
    var folder: Folder
    
    // TODO: Find way to remove forse  unwraping.
    init(name: String) {
        self.folder = try! DocumentsFolder.root.createFolder(with: name)
        self.bundle = Bundle(path: folder.path)!
        self.bundle.load()
    }
}

protocol FileBundleProtocol: CustomBundleProtocol {
    var file: File { get }
}

class FileBundle: CustomBundle, FileBundleProtocol {
    var file: File
    
    init(name: String, fileName: String) {
        let folder = try! DocumentsFolder.root.createFolder(with: name)
        self.file = File(path: folder.path + "/" + fileName)
        super.init(name: name)
    }
}

protocol DictionaryBundleProtocol: CustomBundleProtocol {
    var stringsDictionary: [AnyHashable: Any] { get }
    var file: DictionaryFile { get }
}

class DictionaryBundle: CustomBundle, DictionaryBundleProtocol {
    var stringsDictionary: [AnyHashable: Any]
    var file: DictionaryFile
    
    // TODO: Find way to remove forse  unwraping.
    init(name: String, fileName: String, stringsDictionary: [AnyHashable: Any]) {
        self.stringsDictionary = stringsDictionary
        let folder = try! DocumentsFolder.root.createFolder(with: name)
        self.file = DictionaryFile(path: folder.path + "/" + fileName)
        self.file.file = self.stringsDictionary
        try? self.file.save()
        super.init(name: name)
    }
    
    func remove() {
        try? self.file.remove()
    }
}
