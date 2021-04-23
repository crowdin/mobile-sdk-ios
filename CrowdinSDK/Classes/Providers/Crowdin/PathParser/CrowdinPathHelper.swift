//
//  CrowdinPathHelper.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 4/23/21.
//

import Foundation

struct CrowdinPathHelper {
    
    static func adoptMappingLocalization(languageMapping: LangMapping?, localization: String) -> String {
        guard let langMapping = languageMapping else {
            return localization
        }
        
        if let pattern = langMapping.languagesMapping.first(where: { $0.lang == localization }) {
            let currentPattern = pattern.patterns.first(where: { $0.customCode.count == localization.count })
            return currentPattern?.customCode ?? localization
        } else {
            return localization
        }
    }
}
