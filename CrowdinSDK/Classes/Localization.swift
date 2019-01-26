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
        didSet {
            self.refresh()
        }
    }
    
    init() {
        self.current = preferredLanguageIdentifiers.first(where: { Bundle.main.localizations.contains($0) }) ?? "en"
        self.refresh()
    }
    
    /// Set new localization.
    ///
    /// - Parameter localization: Language IDs.
    func set(localization: String)  {
        self.current = localization
    }
    
    /// A list of all avalaible localization in SDK downloaded from crowdin server.
    var inSDK: [String] {
        return crowdinFolder.files.compactMap({ $0.name })
    }
    
    /// A list of all the localizations contained in the bundle.
    var inBundle: [String] {
        return Bundle.main.localizations
    }
    
//    var bundleLocalization: NSDictionary!
    var sdkLocalization: [String: String] = [:]
    
    func refresh() {
        guard let sdkFile = crowdinFolder.files.filter({ $0.name == current }).first else { return }
        guard let data = sdkFile.content else { return }
         guard let content = try? JSONDecoder().decode([String: String].self, from: data) else { return }
        self.sdkLocalization = content
    }
    
}
