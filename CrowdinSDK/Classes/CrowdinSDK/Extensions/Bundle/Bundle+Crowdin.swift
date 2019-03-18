//
//  Bundle+Crowdin.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/19/19.
//

import Foundation

extension Bundle {
    var crowdinHash: String? {
        return infoDictionary?["CrowdinHash"] as? String
    }
    
    var crowdinStringsFileNames: [String]? {
        return infoDictionary?["CrowdinStringsFileNames"] as? [String]
    }
    
    var crowdinPluralsFileNames: [String]? {
        return infoDictionary?["CrowdinPluralsFileNames"] as? [String]
    }
}
