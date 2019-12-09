// Dangerfile.swift

import Foundation
import Danger
import DangerSwiftLint // package: https://github.com/ashfurrow/DangerSwiftLint.git

let danger = Danger()

warn("Danger Swift is working")

if danger.git.createdFiles.count + danger.git.modifiedFiles.count - danger.git.deletedFiles.count > 10 {
    warn("Big PR, try to keep changes smaller if you can")
}

SwiftLint.lint(directory: "CrowdinSDK/Classes", configFile: "CrowdinSDK/Classes/.swiftlint.yml")
