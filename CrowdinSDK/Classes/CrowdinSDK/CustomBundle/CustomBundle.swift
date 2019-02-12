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
        self.folder = try! DocumentsFolder.createFolder(with: name)
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
        let folder = try! DocumentsFolder.createFolder(with: name)
        self.file = File(path: folder.path + "/" + fileName)
        super.init(name: name)
    }
}

protocol DictionaryBundleProtocol: CustomBundleProtocol {
    var stringsDictionary: NSDictionary { get }
    var file: PlistFile { get }
}

class DictionaryBundle: CustomBundle, DictionaryBundleProtocol {
    var stringsDictionary: NSDictionary
    var file: PlistFile
    
    // TODO: Find way to remove forse  unwraping.
    init(name: String, fileName: String, stringsDictionary: NSDictionary) {
        self.stringsDictionary = stringsDictionary
        let folder = try! DocumentsFolder.createFolder(with: name)
        self.file = PlistFile(path: folder.path + "/" + fileName)
        self.file.file = self.stringsDictionary
        try? self.file.save()
        super.init(name: name)
    }
}
