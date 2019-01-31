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
    
    var locale: String
    
    var files: [String] {
        guard let filePath = Bundle.main.path(forResource: locale, ofType: FileType.lproj.extension) else { return [] }
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: filePath) else { return [] }
        return files
    }
    
    init(locale: String) {
        self.locale = locale
    }
    
    func extract() {
        // TODO: implement extraction of all localization strings.
        
    }
}
