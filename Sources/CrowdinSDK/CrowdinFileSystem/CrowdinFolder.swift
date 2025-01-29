//
//  CrowdinFolder.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

public final class CrowdinFolder: Folder {
    enum Strings: String {
        case dot = "."
        case pathDelimiter = "/"
    }

    enum Folders: String {
        case Crowdin
        case Screenshots
    }

    public static let shared = CrowdinFolder()

    let screenshotsFolder: Folder

    public init() {
        let name = (Bundle.main.bundleIdentifier ?? "") + Strings.dot.rawValue + Folders.Crowdin.rawValue
        guard let rootFolder = ApplicationSupportFolder() ?? CachesFolder() else {
            fatalError("Error while obtaining folder for saving Crowdin files, neither Application Support nor Caches directories is not available.")
        }
        let path = rootFolder.path + Strings.pathDelimiter.rawValue + name
        self.screenshotsFolder = Folder(path: path + Strings.pathDelimiter.rawValue + Folders.Screenshots.rawValue)
        super.init(path: path)
        self.createFoldersIfNeeded()
    }

    public func createFoldersIfNeeded() {
        self.createCrowdinFolderIfNeeded()
        self.createScreenshotsFolderIfNeeded()
    }

    public func createCrowdinFolderIfNeeded() {
        if !self.isCreated { try? self.create() }
    }

    public func createScreenshotsFolderIfNeeded() {
        if !screenshotsFolder.isCreated { try? screenshotsFolder.create() }
    }
}
