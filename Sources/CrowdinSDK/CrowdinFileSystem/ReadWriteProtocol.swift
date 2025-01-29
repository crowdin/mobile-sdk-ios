//
//  ReadWriteProtocol.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/10/19.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
import Foundation

public protocol ReadWriteProtocol {
    func write(to path: String)
    static func read(from path: String) -> Self?
}

extension NSDictionary: ReadWriteProtocol {
    public func write(to path: String) {
        self.write(toFile: path, atomically: true)
    }

    public static func read(from path: String) -> Self? {
        return self.init(contentsOfFile: path)
    }
}

extension Dictionary: ReadWriteProtocol {
    public func write(to path: String) {
        NSDictionary(dictionary: self).write(toFile: path, atomically: true)
    }

    public static func read(from path: String) -> Dictionary<Key, Value>? {
        return NSDictionary(contentsOfFile: path) as? Dictionary
    }
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension UIImage: ReadWriteProtocol {
    public static func read(from path: String) -> Self? {
        return self.init(contentsOfFile: path)
    }

    public func write(to path: String) {
        try? self.pngData()?.write(to: URL(fileURLWithPath: path))
    }
}
#endif

/// TODO: Add custon JSONEncode & JSONDecoder support.
public class CodableWrapper<T: Codable> {
    var object: T

    required init(object: T) {
        self.object = object
    }
}

extension CodableWrapper: ReadWriteProtocol {
    public func write(to path: String) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        try? data.write(to: URL(fileURLWithPath: path))
    }

    public static func read(from path: String) -> Self? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        guard let object = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        return self.init(object: object)
    }
}

extension Data: ReadWriteProtocol {
    public func write(to path: String) {
        do {
            let url = URL(fileURLWithPath: path)
            try Folder(path: url.deletingLastPathComponent().relativePath).create()
            try self.write(to: url)
        } catch {
            print(error)
        }
    }

    public static func read(from path: String) -> Data? {
        try? Data(contentsOf: URL(fileURLWithPath: path))
    }
}
