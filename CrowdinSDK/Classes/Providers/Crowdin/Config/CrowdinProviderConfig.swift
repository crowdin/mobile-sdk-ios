//
//  CrowdinProviderConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

@objcMembers public class CrowdinProviderConfig: NSObject {
    var hashString: String
    var stringsFileNames: [String]
    var pluralsFileNames: [String]
    var localizations: [String]
    var sourceLanguage: String
    
    public init(hashString: String, files: [String], localizations: [String], sourceLanguage: String) {
        self.hashString = hashString
        self.stringsFileNames = files.filter({ $0.isStrings })
        self.pluralsFileNames = files.filter({ $0.isStringsDict })
        self.localizations = localizations
        self.sourceLanguage = sourceLanguage
    }
    
    public override init() {
        guard let hashString = Bundle.main.crowdinHash else {
            fatalError("Please add CrowdinHash key to your Info.plist file")
        }
        self.hashString = hashString
        guard let localizations = Bundle.main.cw_localizations else {
            fatalError("Please add CrowdinLocalizations key to your Info.plist file")
        }
        self.localizations = localizations
        guard let crowdinFiles = Bundle.main.crowdinFiles else {
            fatalError("Please add CrowdinFiles key to your Info.plist file")
        }
        self.stringsFileNames = crowdinFiles.filter({ $0.isStrings })
        self.pluralsFileNames = crowdinFiles.filter({ $0.isStringsDict })
        
        guard let crowdinSourceLanguage = Bundle.main.crowdinSourceLanguage else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.sourceLanguage = crowdinSourceLanguage
    }
}
