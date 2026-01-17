//
//  RULocalLocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.02.2020.
//

import Foundation

class RULocalLocalizationStorage: LocalLocalizationStorage {
    override init(localization: String) {
        super.init(localization: localization)
        if let folder = try? CrowdinFolder.shared.createFolder(with: "RealtimeUpdates") {
            self.localizationFolder = folder
        }
    }
}
