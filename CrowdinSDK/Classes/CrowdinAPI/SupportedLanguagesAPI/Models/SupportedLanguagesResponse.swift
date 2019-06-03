//
//  SupportedLanguagesResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

typealias SupportedLanguagesResponse = [SupportedLanguagesLanguage]

class SupportedLanguagesLanguage: Codable {
    let name: String?
    let crowdinCode: String?
    let editorCode: String?
    let iso639_1: String?
    let iso639_3: String?
    let locale: String?
    let androidCode: String?
    let osxCode: String?
    let osxLocale: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case crowdinCode = "crowdin_code"
        case editorCode = "editor_code"
        case iso639_1 = "iso_639_1"
        case iso639_3 = "iso_639_3"
        case locale = "locale"
        case androidCode = "android_code"
        case osxCode = "osx_code"
        case osxLocale = "osx_locale"
    }
    
    init(name: String?, crowdinCode: String?, editorCode: String?, iso639_1: String?, iso639_3: String?, locale: String?, androidCode: String?, osxCode: String?, osxLocale: String?) {
        self.name = name
        self.crowdinCode = crowdinCode
        self.editorCode = editorCode
        self.iso639_1 = iso639_1
        self.iso639_3 = iso639_3
        self.locale = locale
        self.androidCode = androidCode
        self.osxCode = osxCode
        self.osxLocale = osxLocale
    }
}
