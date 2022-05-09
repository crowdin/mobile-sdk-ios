//
//  DocumentsFolder.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

class SystemFolder: Folder {
    init?(searchPath: FileManager.SearchPathDirectory) {
        guard let url = try? FileManager.default.url(for: searchPath, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return nil
        }
        super.init(path: url.path)
    }
}

class ApplicationSupportFolder: SystemFolder {
    init?() {
        super.init(searchPath: .applicationSupportDirectory)
    }
}

class DocumentsFolder: SystemFolder {
    init?() {
        super.init(searchPath: .documentDirectory)
    }
}

class CachesFolder: SystemFolder {
    init?() {
        super.init(searchPath: .cachesDirectory)
    }
}
