//
//  LanguageResolver.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 02.11.2021.
//

import Foundation

extension ManifestManager: LanguageResolver {
    var allLanguages: [CrowdinLanguage] {
        // Access supportedLanguages outside queue.sync to avoid nested synchronization
        let crowdinLanguages: [CrowdinLanguage] = crowdinSupportedLanguages.supportedLanguages ?? []
        let custom = customLanguages
        return ManifestManager.mergeLanguages(supported: crowdinLanguages, custom: custom)
    }
    
    /// Get crowdin language locale code for iOS localization code.
    /// - Parameter localization: iOS localization identifier. (List of all - Locale.availableIdentifiers).
    /// - Returns: Id of iOS localization code in crowdin system.
    func crowdinLanguageCode(for localization: String) -> String? {
        crowdinSupportedLanguage(for: localization)?.id
    }

    func crowdinSupportedLanguage(for localization: String) -> CrowdinLanguage? {
        // Access supportedLanguages outside queue.sync to avoid nested synchronization
        let crowdinLanguages: [CrowdinLanguage] = crowdinSupportedLanguages.supportedLanguages ?? []
        let custom = customLanguages
        let languages: [CrowdinLanguage] = ManifestManager.mergeLanguages(
            supported: crowdinLanguages,
            custom: custom
        )
        
        var language = languages.first(where: { $0.iOSLanguageCode == localization })
        if language == nil {
            // This is possible for languages ​​with regions. In case we didn't find Crowdin language mapping, try to replace _ in location code with -
            let alternateiOSLocaleCode = localization.replacingOccurrences(of: "_", with: "-")
            language = languages.first(where: { $0.iOSLanguageCode == alternateiOSLocaleCode })
        }
        if language == nil {
            // This is possible for languages ​​with regions. In case we didn't find Crowdin language mapping, try to get localization code and search again
            let alternateiOSLocaleCode = localization.split(separator: "_").map({ String($0) }).first
            language = languages.first(where: { $0.iOSLanguageCode == alternateiOSLocaleCode })
        }
        return language
    }

    func iOSLanguageCode(for crowdinLocalization: String) -> String? {
        // Access supportedLanguages outside queue.sync to avoid nested synchronization
        let crowdinLanguages: [CrowdinLanguage] = crowdinSupportedLanguages.supportedLanguages ?? []
        let custom = customLanguages
        let languages: [CrowdinLanguage] = ManifestManager.mergeLanguages(
            supported: crowdinLanguages,
            custom: custom
        )
        
        return languages.first(where: { $0.id == crowdinLocalization })?.iOSLanguageCode
    }

    /// Returns the language key used inside an xcstrings file for the given iOS localization.
    ///
    /// Standard Crowdin languages use their `osxLocale` as the xcstrings key (e.g. "de", "zh-Hans").
    /// Custom languages have an `osxLocale` that acts as the iOS locale folder name (e.g. "tra", "SRXK")
    /// but the xcstrings file stores their translations under the BCP 47 locale derived from the
    /// custom language's `locale` field (e.g. "to" for "to-To", "sr-XK" for "sr-XK").
    func xcstringsParsingKey(for localization: String) -> String {
        let custom = customLanguages
        guard let language = crowdinSupportedLanguage(for: localization),
              custom.contains(where: { $0.id == language.id }) else {
            // Standard language: the iOS localization is already the xcstrings key.
            return localization
        }
        // Custom language: derive the xcstrings key from the locale field.
        // Replace underscores with hyphens to get BCP 47 format, then strip a redundant
        // region subtag when it matches the language subtag (e.g. "to-To" → "to").
        let normalizedLocale = language.locale.replacingOccurrences(of: "_", with: "-")
        let parts = normalizedLocale.components(separatedBy: "-")
        if parts.count == 2 && parts[0].lowercased() == parts[1].lowercased() {
            return parts[0]
        }
        return normalizedLocale
    }
}
