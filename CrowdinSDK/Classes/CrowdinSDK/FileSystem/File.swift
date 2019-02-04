//
//  File.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit

enum FileStatus {
    case file
    case directory
    case none
}

protocol FileStatusable {
    var status: FileStatus { get }
}

extension FileStatusable where Self : Path {
    var status: FileStatus {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
            if isDir.boolValue {
                return .directory
            } else {
                return .file
            }
        } else {
            return .none
        }
    }
}

protocol Path {
    var path: String { get set}
}

class File: Path, FileStatusable {
    var path: String
    let name: String
    let type: String
    
    init(path: String) {
        self.path = path
        let url = URL(fileURLWithPath: path)
        guard let lastPathComponent = url.pathComponents.last else {
            fatalError("Error while creating a file at path - \(path)")
        }
        let components = lastPathComponent.split(separator: ".")
        guard components.count > 0 else {
            fatalError("Error while detecting file name and type, from path - \(path)")
        }
        if components.count == 1 {
            //Hidden file f.e. .DS_Store
            name = ""
            type = String(components[0])
        } else {
            type = String(components.last!)
            var fileName = lastPathComponent.replacingOccurrences(of: type, with: "")
            fileName.removeLast()
            name = fileName
        }
    }
    
    var isCreated: Bool { return status == .file }
    
    var content: Data? {
        guard self.isCreated else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
}

class ImageFile: File {
    var image: UIImage? = nil
    
    override init(path: String) {
        super.init(path: path)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
        self.image = UIImage(data: data)
    }
    
    func save() throws {
        guard let image = self.image else { return }
        try image.save(self.path)
    }
}
