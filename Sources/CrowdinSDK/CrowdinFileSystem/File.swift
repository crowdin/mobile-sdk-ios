//
//  File.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
import Foundation

public protocol PathProtocol {
    var path: String { get set }
}

public protocol FileProtocol: PathProtocol {
    var name: String { get set }
    var type: String { get set }
    var isCreated: Bool { get }
    var content: Data? { get }

    func create()
    func remove() throws
}

public class File: FileProtocol, FileStatsProtocol {
    public var path: String
    public var name: String
    public var type: String

    public init(path: String) {
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
            // Hidden file f.e. .DS_Store
            name = ""
            type = String(components[0])
        } else if components.count > 1 {
            // swiftlint:disable force_unwrapping
            type = String(components.last!)
            var fileName = lastPathComponent.replacingOccurrences(of: type, with: "")
            fileName.removeLast()
            name = fileName
        } else {
            name = ""
            type = ""
        }
    }

    public var isCreated: Bool { return status == .file }

    public var content: Data? {
        guard self.isCreated else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }

    public func remove() throws {
        try FileManager.default.removeItem(atPath: path)
    }

    public func create() {
		FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
	}
}

class ReadWriteFile<T: ReadWriteProtocol>: File {
    var file: T? = nil

    override init(path: String) {
        super.init(path: path)
        self.file = T.read(from: path)
    }

    func save() throws {
        guard let file = self.file else { return }
        file.write(to: self.path)
    }
}

#if os(iOS) || os(tvOS) || os(watchOS)
class UIImageFile: ReadWriteFile<UIImage> {}
#endif

class NSDictionaryFile: ReadWriteFile<NSDictionary> {}

class DictionaryFile: ReadWriteFile<Dictionary<AnyHashable, Any>> {}

class StringsFile: ReadWriteFile<Dictionary<String, String>> {
    override func save() throws {
        guard let file = self.file else { return }
        var string = ""
        file.forEach({ (key, value) in
            string += "\"\(key)\" = \"\(value)\";\n"
        })
        try? string.write(toFile: self.path, atomically: true, encoding: .utf8)
    }
}
