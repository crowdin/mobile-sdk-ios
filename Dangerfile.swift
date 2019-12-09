// Dangerfile.swift

import Danger
import DangerSwiftLint // package: https://github.com/ashfurrow/danger-swiftlint.git

SwiftLint.lint(directory: "CrowdinSDK/Classes", configFile: "CrowdinSDK/Classes/.swiftlint.yml")
