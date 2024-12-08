// Dangerfile.swift

import Foundation
import Danger

let danger = Danger()

if danger.git.createdFiles.count + danger.git.modifiedFiles.count - danger.git.deletedFiles.count > 10 {
    warn("Big PR, try to keep changes smaller if you can")
}

SwiftLint.lint(.all(directory: "Sources/CrowdinSDK"), configFile: "Sources/CrowdinSDK/.swiftlint.yml")
