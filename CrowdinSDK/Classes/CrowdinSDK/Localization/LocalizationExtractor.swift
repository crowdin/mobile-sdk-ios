//
//  LocalizationExtractor.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

class LocalizationExtractor {
    static var allLocalizations: [String] {
        return Bundle.main.preferredLocalizations
    }
    var allKeys: [String] = []
    var allValues: [String] = []
    var localizationDict: [String: String] = [:]
    
    var localization: String? = LocalizationExtractor.allLocalizations.first
    
    var files: [String] {
        guard let filePath = Bundle.main.path(forResource: localization, ofType: FileType.lproj.extension) else { return [] }
        guard var files = try? FileManager.default.contentsOfDirectory(atPath: filePath) else { return [] }
        files = files.map({ filePath + "/" + $0 })
        return files
    }
    
    init(localization: String? = LocalizationExtractor.allLocalizations.first) {
        self.localization = localization
        self.extract()
    }
    
    func setLocalization(_ localization: String?) {
        self.localization = localization
        if localization == nil {
            self.localization = LocalizationExtractor.allLocalizations.first
        }
        self.extract()
    }
    
    func extract() {
        self.files.forEach { (file) in
            guard let dict = NSDictionary(contentsOfFile: file) else { return }
            self.localizationDict.merge(dict: dict as! [String : String])
        }
        /*
        print("self.localization - \(self.localization)")
        var localizationString: String = ""
        self.localization.keys.forEach { (key) in
            localizationString = localizationString + "\"\(key)\" : \"\(self.localization[key] as! String) [\(self.locale)]\"," + "\n"
        }
        print(localizationString)
         */
    }
}
