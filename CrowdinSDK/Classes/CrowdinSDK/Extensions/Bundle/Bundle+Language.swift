//
//  Bundle+Language.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/5/19.
//

import Foundation

extension Bundle {
    var preferredLanguages: [String] {
        let preferredLanguages = Locale.preferredLanguages
        var localizations = self.localizations
        localizations.sort { (str1, str2) -> Bool in
            var firstIndex = preferredLanguages.firstIndex(where: { $0.contains(str1) && $0.count == str1.count })
            if firstIndex == nil {
                firstIndex = preferredLanguages.firstIndex(where: { $0.contains(str1)}) ?? 0
            }
            var secondIndex = preferredLanguages.firstIndex(where: { $0.contains(str2) && $0.count == str2.count })
            if secondIndex == nil {
                secondIndex = preferredLanguages.firstIndex(where: { $0.contains(str2)}) ?? -0
            }
            return firstIndex! < secondIndex!
        }
        return localizations
    }
}
