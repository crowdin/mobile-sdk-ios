//
//  Folder.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation

public protocol FolderProtocol: PathProtocol, FileStatsProtocol {
    var name: String { get }
    var files: [File] { get }
    var directories: [FolderProtocol] { get }
    var isCreated: Bool { get }

    func create() throws
    func remove() throws
    func move(to path: String) throws
    func createFolder(with name: String) throws -> FolderProtocol
}

public class Folder: FolderProtocol {
    enum Strings: String {
        case pathDelimiter = "/"
    }
    fileprivate let fileManager = FileManager.default

    public var path: String
    public var name: String

    public init(path: String) {
        let url = URL(fileURLWithPath: path)
        guard let lastPathComponent = url.pathComponents.last else {
            fatalError("Error while creating a folder at path - \(path)")
        }
        self.name = String(lastPathComponent)
        self.path = path
        self.createFolderIfNeeded()
    }

    public var files: [File] {
        let allContent = self.contents.compactMap({ File(path: path + Strings.pathDelimiter.rawValue + $0) })
        return allContent.filter({ $0.status == .file && $0.name.count > 0 })
    }

    public var directories: [FolderProtocol] {
        let allContent = self.contents.compactMap({ Folder(path: path + Strings.pathDelimiter.rawValue + $0) })
        return allContent.filter({ $0.status == .directory })
    }

    public var isCreated: Bool {
        return self.status == .directory
    }

    public func create() throws {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }

    public func remove() throws {
        try fileManager.removeItem(atPath: path)
    }

    public func move(to path: String) throws {
        try fileManager.moveItem(atPath: self.path, toPath: path)
        self.path = path
    }

    public func file(with name: String) -> FileProtocol? {
        let file = File(path: self.path + Strings.pathDelimiter.rawValue + name)
        guard file.isCreated else { return nil }
        return file
    }

    public func folder(with name: String) -> FolderProtocol? {
        let folder = Folder(path: self.path + Strings.pathDelimiter.rawValue + name)
        guard folder.isCreated else { return nil }
        return folder
    }

    public func createFolder(with name: String) throws -> FolderProtocol {
        let folder = Folder(path: self.path + Strings.pathDelimiter.rawValue + name)
        if !folder.isCreated { try folder.create() }
        return folder
    }
}

extension Folder {
    fileprivate func createFolderIfNeeded() {
        if !self.isCreated { try? self.create() }
    }

    fileprivate var contents: [String] {
        return (try? fileManager.contentsOfDirectory(atPath: path)) ?? []
    }
}
