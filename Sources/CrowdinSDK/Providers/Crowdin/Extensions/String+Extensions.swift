//
//  String+Extensions.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 16.10.2019.
//

import Foundation

enum FileExtensions: String {
    case strings
    case stringsdict
    case xliff
    case json
    case xcstrings
    
    var `extension`: String {
        return ".\(self.rawValue)"
    }
}

extension String {
    var isStrings: Bool {
        hasSuffix(FileExtensions.strings.extension)
    }
    
    var isStringsDict: Bool {
        hasSuffix(FileExtensions.stringsdict.extension)
    }
    
    var isXliff: Bool {
        hasSuffix(FileExtensions.xliff.extension)
    }
    
    var isJson: Bool {
        hasSuffix(FileExtensions.json.extension)
    }
    
    var isXcstrings: Bool {
        hasSuffix(FileExtensions.xcstrings.extension)
    }
}
