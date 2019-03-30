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
    
    var localization: String = Bundle.main.preferredLanguage
    
    var isEmpty: Bool {
        return self.localizationDict.isEmpty && self.localizationPluralsDict.isEmpty
    }
    
    var stringsFiles: [String] {
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
    
    init(localization: String = Bundle.main.preferredLanguage) {
        self.localization = localization
        self.extract()
        // If we're unable to extract localization passed/detected language then try to extract Base localization.
        if self.isEmpty, let developmentRegion = Bundle.main.developmentRegion {
            self.localization = developmentRegion
            self.extract()
        }
    }
    
    func setLocalization(_ localization: String = Bundle.main.preferredLanguage) {
        self.localization = localization
        self.extract()
    }
    
    func extract() {
        self.stringsFiles.forEach { (file) in
            guard let dict = NSDictionary(contentsOfFile: file) else { return }
            self.localizationDict.merge(with: dict as? [String: String] ?? [:])
        }
        
        self.stringsdictFiles.forEach { (file) in
            guard let dict = NSMutableDictionary (contentsOfFile: file) else { return }
			guard let strings = dict as? [AnyHashable: Any] else { return }
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
			if !extractor.localizationDict.isEmpty {
				dict[Keys.strings.rawValue] = extractor.localizationDict
			}
			if !extractor.localizationPluralsDict.isEmpty {
				dict[Keys.plurals.rawValue] = extractor.localizationPluralsDict
			}
			result[localization] = dict
		}
		return result
	}
    
    func extractLocalizationStrings(to path: String) -> StringsFile {
        let file = StringsFile(path: path + String.pathDelimiter + localization + FileType.strings.extension)
        file.file = self.localizationDict
        try? file.save()
        return file
    }
    
    static func extractAllLocalizationStrings(to path: String) {
        self.allLocalizations.forEach { (localization) in
            let ectractor = LocalizationExtractor(localization: localization)
            _ = ectractor.extractLocalizationStrings(to: path)
        }
    }
    
    func extractLocalizationPlurals(to path: String) -> DictionaryFile {
        let file = DictionaryFile(path: path + String.pathDelimiter + localization + FileType.stringsdict.extension)
        file.file = self.localizationPluralsDict
        try? file.save()
        return file
    }
    
    static func extractAllLocalizationPlurals(to path: String) {
        self.allLocalizations.forEach { (localization) in
            let ectractor = LocalizationExtractor(localization: localization)
            _ = ectractor.extractLocalizationPlurals(to: path)
        }
    }
}
