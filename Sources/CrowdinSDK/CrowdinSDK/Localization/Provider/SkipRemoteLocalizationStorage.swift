//
//  SkipRemoteLocalizationStorage.swift
//  CrowdinSDK
//

import Foundation

class SkipRemoteLocalizationStorage: RemoteLocalizationStorageProtocol {

    var name: String = "Crowdin"

    var localizations: [String] = []

    var localization: String = ""

    func deintegrate() {
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Skip \(#function)"))
    }

    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Skip \(#function)"))
        completion(nil, localization, nil, nil)
    }

    func prepare(with completion: @escaping () -> Void) {
        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Skip \(#function)"))
        DispatchQueue.main.async {
            completion()
        }
    }
}
