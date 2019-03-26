//
//  SupportedLanguagesResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

typealias SupportedLanguagesResponse = [SupportedLanguagesLanguage]

public class SupportedLanguagesLanguage: Codable {
    public let name: String?
    public let crowdinCode: String?
    public let editorCode: String?
    public let iso639_1: String?
    public let iso639_3: String?
    public let locale: String?
    public let androidCode: String?
    public let osxCode: String?
    public let osxLocale: String?
    
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
    
    public init(name: String?, crowdinCode: String?, editorCode: String?, iso639_1: String?, iso639_3: String?, locale: String?, androidCode: String?, osxCode: String?, osxLocale: String?) {
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
