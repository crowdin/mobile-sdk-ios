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
        do {
            self.localizationFolder = try CrowdinFolder.shared.createFolder(with: "RealtimeUpdates")
        } catch {
            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Failed to create RealtimeUpdates folder: \(error.localizedDescription). Falling back to root CrowdinFolder."))
            self.localizationFolder = CrowdinFolder.shared
        }
    }
}
