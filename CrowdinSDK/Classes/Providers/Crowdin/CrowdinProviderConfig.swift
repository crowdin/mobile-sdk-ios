//
//  CrowdinProviderConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

@objcMembers public class CrowdinProviderConfig {
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    var localizations: [String]
    
    public init(hashString: String, stringsFileNames: [String], pluralsFileNames: [String], localizations: [String]) {
        self.hashString = hashString
        self.stringsFileNames = stringsFileNames
        self.pluralsFileNames = pluralsFileNames
        self.localizations = localizations
    }
}
