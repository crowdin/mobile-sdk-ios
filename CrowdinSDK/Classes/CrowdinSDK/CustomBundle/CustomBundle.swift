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

class FolderBundle: CustomBundleProtocol {
    var bundle: Bundle
    var folder: Folder
    
    // TODO: Find way to remove forse  unwraping.
    init(folder: Folder) {
        self.folder = folder
        self.bundle = Bundle(path: folder.path)!
        self.bundle.load()
    }
}

class PathBundle: CustomBundleProtocol {
	var bundle: Bundle
	var folder: Folder
	
	// TODO: Find way to remove forse  unwraping.
	init(path: String) {
		self.folder = Folder(path: path)
		self.bundle = Bundle(path: folder.path)!
		self.bundle.load()
	}
}

protocol FileBundleProtocol: CustomBundleProtocol {
    var file: File { get }
}

class FileBundle: PathBundle, FileBundleProtocol {
    var file: File
    
    init(path: String, fileName: String) {
        let folder = Folder(path: path)
        self.file = File(path: folder.path + "/" + fileName)
        super.init(path: path)
    }
}

protocol DictionaryBundleProtocol: CustomBundleProtocol {
	var dictionary: Dictionary<AnyHashable, Any> { get }
    var file: DictionaryFile { get }
}

class DictionaryBundle: PathBundle, DictionaryBundleProtocol {
	var dictionary: Dictionary<AnyHashable, Any>
    var file: DictionaryFile
    
    // TODO: Find way to remove forse  unwraping.
    init(path: String, fileName: String, dictionary: [AnyHashable: Any]) {
        self.dictionary = dictionary
        let folder = Folder(path: path)
        self.file = DictionaryFile(path: folder.path + "/" + fileName)
        self.file.file = self.dictionary
        try? self.file.save()
        super.init(path: path)
    }
    
    func remove() {
		self.bundle.unload()
		try? self.folder.remove()
        try? self.file.remove()
    }
}
