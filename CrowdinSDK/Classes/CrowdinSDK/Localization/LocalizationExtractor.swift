//
//  LocalizationExtractor.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

class LocalizationExtractor {
    static var allLocalizations: [String] {
        return Bundle.main.localizations
    }
    
    var allKeys: [String] = []
    var allValues: [String] = []
    var localizationDict: [String: String] = [:]
	var localizationPluralsDict: [AnyHashable: Any] = [:]
    
    var localization: String? = LocalizationExtractor.allLocalizations.first
    
    var files: [String] {
        guard let filePath = Bundle.main.path(forResource: localization, ofType: FileType.lproj.rawValue) else { return [] }
        guard var files = try? FileManager.default.contentsOfDirectory(atPath: filePath) else { return [] }
        files = files.map({ filePath + String.pathDelimiter + $0 })
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
			guard let strings = dict as? [AnyHashable : Any] else { return }
			self.localizationPluralsDict = self.localizationPluralsDict + strings
        }
    }
	
	static func extractLocalizationJSONFile(to path: String) {
		let json = self.extractLocalizationJSON()
		guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return }
		try? data.write(to: URL(fileURLWithPath: path))
	}
	
	static func extractLocalizationJSON() -> [String: Any] {
		var result = [String: Any]()
		self.allLocalizations.forEach { (localization) in
			let extractor = LocalizationExtractor(localization: localization)
			var dict = [String: Any]()
			dict["app_version"] = Bundle.main.versionNumber
			if !extractor.localizationDict.isEmpty {
				dict["strings"] = extractor.localizationDict
			}
			if !extractor.localizationPluralsDict.isEmpty {
				dict["plurals"] = extractor.localizationPluralsDict
			}
			result[localization] = dict
		}
		return result
	}
}
