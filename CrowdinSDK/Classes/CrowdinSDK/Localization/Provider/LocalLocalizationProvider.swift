//
//  LocalLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/13/19.
//

import Foundation

public class LocalLocalizationProvider: BaseLocalizationProvider {
    public override init() {
        super.init()
        self.localizations = Bundle.main.localizations
    }
    
    required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        super.init(localizations: localizations, strings: strings, plurals: plurals)
        self.localizations = Bundle.main.localizations
    }
    
    override public func set(localization: String?) {
        super.set(localization: localization)
        refresh()
    }
    
    func refresh() {
        let extractor = LocalizationExtractor(localization: self.localization)
        self.set(plurals: extractor.localizationPluralsDict)
        self.set(strings: [localization: extractor.localizationDict])
    }
}
