//
//  Folder.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation

class Folder: Path, FileStatusable {
    let fileManager = FileManager.default
    var path: String
    var name: String
    
    var contents: [String] {
        return (try? fileManager.contentsOfDirectory(atPath: path)) ?? []
    }
    
    init(path: String) {
        let url = URL(fileURLWithPath: path)
        guard let lastPathComponent = url.pathComponents.last else {
            fatalError("Error while creating a file at path - \(path)")
        }
        self.name = String(lastPathComponent)
        self.path = path
        self.createFolderIfNeeded()
    }
    // Private
    private func createFolderIfNeeded() {
        if !self.isCreated { try? self.create() }
    }
    
    var files: [File] {
        let allContent = self.contents.compactMap({ File(path: path + "/" + $0) })
        return allContent.filter({ $0.status == .file && $0.name.count > 0 })
    }
    
    var directories: [Folder] {
        let allContent = self.contents.compactMap({ Folder(path: path + "/" + $0) })
        return allContent.filter({ $0.status == .directory })
    }
    
    var isCreated: Bool {
        return self.status == .directory
    }
    
    func create() throws {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    func remove() throws {
        try fileManager.removeItem(atPath: path)
    }
    
    func move(to path: String) throws {
        try fileManager.moveItem(atPath: self.path, toPath: path)
        self.path = path
    }
    
    func createFolder(with name: String) throws -> Folder {
        let folder = Folder(path: self.path + "/" + name)
        if !folder.isCreated { try folder.create() }
        return folder
    }
    
    static func createFolder(with name: String) throws -> Folder {
        let folder = Folder(path: DocumentsFolder.documentsPath + "/" + name)
        if !folder.isCreated { try folder.create() }
        return folder
    }
}

class DocumentsFolder: Folder {
    static let root = DocumentsFolder()
    
    static let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    init(_ path: String) {
        super.init(path: path)
    }
    
    init() {
        super.init(path: DocumentsFolder.documentsPath)
    }
    
    init(name: String) {
        super.init(path: DocumentsFolder.documentsPath + "/" + name)
    }
}


class CrowdinFolder: Folder {
    enum Folders: String {
        case Crowdin
        case Screenshots
    }
    
	static let shared = CrowdinFolder()
	
	let screenshotsFolder: Folder
	
	init() {
		let name = Bundle.main.bundleId + "." + Folders.Crowdin.rawValue
        let path = DocumentsFolder.root.path + "/" + name
        self.screenshotsFolder = Folder(path: path + "/" + Folders.Screenshots.rawValue)
		super.init(path: path)
		self.createFoldersIfNeeded()
	}
	
	func createFoldersIfNeeded() {
		self.createCrowdinFolderIfNeeded()
		self.createScreenshotsFolderIfNeeded()
	}
	
	func createCrowdinFolderIfNeeded() {
		if !self.isCreated { try? self.create() }
	}
	
	func createScreenshotsFolderIfNeeded() {
		if !screenshotsFolder.isCreated { try? screenshotsFolder.create() }
	}
}
