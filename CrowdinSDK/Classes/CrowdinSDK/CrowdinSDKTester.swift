//
//  CrowdinSDKTester.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/24/19.
//

import Foundation

public class CrowdinSDKTester {
    var localization: String
    let localizationFile: DictionaryFile
    
    public init(localization: String) {
        self.localization = localization
        let path = CrowdinFolder.shared.path + String.pathDelimiter + Strings.Crowdin.rawValue + String.pathDelimiter + localization + FileType.plist.extension
        self.localizationFile = DictionaryFile(path: path)
    }
    
    public var downloadedLocalizations: [String] {
        return CrowdinFolder.shared.files.map({ $0.name })
    }
    
    public var inSDKStringsKeys: [String] {
        guard let strings = localizationFile.file?[Keys.strings.rawValue] as? [String : String] else { return [] }
        return strings.keys.map({ $0 })
    }
    
    public var inSDKPluralsKeys: [String] {
        guard let strings = localizationFile.file?[Keys.plurals.rawValue] as? [AnyHashable : Any] else { return [] }
        return strings.keys.map({ $0 as! String })
    }
}
