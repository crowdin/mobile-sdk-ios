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
}

extension String {
    var isStrings: Bool {
        hasSuffix(FileExtensions.strings.rawValue)
    }
    
    var isStringsDict: Bool {
        hasSuffix(FileExtensions.stringsdict.rawValue)
    }
    
    var isXliff: Bool {
        hasSuffix(FileExtensions.xliff.rawValue)
    }
    
    var isJson: Bool {
        hasSuffix(FileExtensions.json.rawValue)
    }
    
    var isXcstrings: Bool {
        hasSuffix(FileExtensions.xcstrings.rawValue)
    }
}
