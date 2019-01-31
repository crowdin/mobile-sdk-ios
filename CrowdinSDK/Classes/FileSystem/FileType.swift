//
//  FileType.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

enum FileType: String {
    case lproj
    case strings
    
    var `extension`: String {
        return ".\(self.rawValue)"
    }
}
