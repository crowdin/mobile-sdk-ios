//
//  FileStatus.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

public enum FileStatus {
    case file
    case directory
    case none
}

public protocol FileStatsProtocol {
    var status: FileStatus { get }
}

extension FileStatsProtocol where Self: PathProtocol {
    public var status: FileStatus {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
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
