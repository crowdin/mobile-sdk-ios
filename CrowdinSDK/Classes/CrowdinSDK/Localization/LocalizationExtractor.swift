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
    var localizationPluralsDict: NSMutableDictionary = NSMutableDictionary()
    
    var localization: String? = LocalizationExtractor.allLocalizations.first
    
    var files: [String] {
        guard let filePath = Bundle.main.path(forResource: localization, ofType: FileType.lproj.rawValue) else { return [] }
        guard var files = try? FileManager.default.contentsOfDirectory(atPath: filePath) else { return [] }
        files = files.map({ filePath + "/" + $0 })
        return files
    }
    var stringsdictFiles: [String] {
        guard let filePath = Bundle.main.path(forResource: localization, ofType: FileType.lproj.extension) else { return [] }
        let folder = Folder(path: filePath)
        let files = folder.files.filter({ $0.type == FileType.stringsdict.rawValue })
        return files.map({ $0.path })
    }
    
    init(localization: String? = LocalizationExtractor.allLocalizations.first) {
        self.localization = localization
        if localization == nil {
            self.localization = LocalizationExtractor.allLocalizations.first
        }
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
            self.localizationDict.merge(dict: dict as? [String : String] ?? [:])
        }
        
        self.stringsdictFiles.forEach { (file) in
            guard let dict = NSMutableDictionary (contentsOfFile: file) else { return }
            
            dict.allKeys.forEach({ (key) in
                let localized = dict[key] as! NSMutableDictionary
                localized.allKeys.forEach({ (key1) in
                    if key1 as! String == "NSStringLocalizedFormatKey" {
                        return
                    }
                    var value = localized[key1] as! [String: String]
                    value.keys.forEach({ (key) in
                        value[key] = value[key]! + "[C]"
                    })
                    localized.setValue(value, forKey: key1 as! String)
                })
            })
            
            self.localizationPluralsDict.addEntries(from: dict as? [AnyHashable : Any] ?? [:])
        }
    }
}
