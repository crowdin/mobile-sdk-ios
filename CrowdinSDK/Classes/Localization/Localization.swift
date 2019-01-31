//
//  Localization.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/25/19.
//

import Foundation

class Localization {
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
    let preferredLanguageIdentifiers = Locale.preferredLanguageIdentifiers
    
    static var shared = Localization()
    
    var current : String {
        set {
            guard current != newValue else { return }
            UserDefaults.standard.set(newValue, forKey: "CrowdinSDK.Localization.current")
            UserDefaults.standard.synchronize()
            self.refresh()
        }
        get {
            var value = UserDefaults.standard.string(forKey: "CrowdinSDK.Localization.current")
            if value == nil {
                value = preferredLanguageIdentifiers.first(where: { Bundle.main.localizations.contains($0) }) ?? "en"
            }
            return value!
        }
    }
    
    init() {
        self.refresh()
        self.readAllAvalaibleKeysAndValues()
    }
    
    /// Set new localization.
    ///
    /// - Parameter localization: Language IDs. Pass nil for autodetection.
    func set(localization: String?)  {
        if let localization = localization {
            self.current = localization
        } else {
            self.current = preferredLanguageIdentifiers.first(where: { Bundle.main.localizations.contains($0) }) ?? "en"
        }
    }
    
    /// A list of all avalaible localization in SDK downloaded from crowdin server.
    var inSDK: [String] {
        return crowdinFolder.files.compactMap({ $0.name })
    }
    
    /// A list of all the localizations contained in the bundle.
    var inBundle: [String] {
        return Bundle.main.localizations
    }
    var allSDKKeys: [String] = []
    var allSDKValues: [String] = []
    var sdkLocalization: [String: String] = [:]
    
    func refresh() {
        guard let sdkFile = crowdinFolder.files.filter({ $0.name == current }).first else { return }
        guard let data = sdkFile.content else { return }
        guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
        self.sdkLocalization = content
    }
    
    func readAllAvalaibleKeysAndValues() {
        crowdinFolder.files.forEach({
            guard let data = $0.content else { return }
            guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
            allSDKKeys.append(contentsOf: content.keys)
            allSDKValues.append(contentsOf: content.values)
        })
        let uniqueValues: Set<String> = Set<String>(allSDKKeys)
        allSDKKeys = ([String])(uniqueValues)
    }
}
