//
//  LocalizationProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

public typealias LocalizationStorageCompletion = (_ localizations: [String], _ strings: [String: String], _ plurals: [AnyHashable: Any]) -> Void

@objc public protocol LocalizationStorage {
    var localization: String { get set }
    func fetchData(completion: @escaping LocalizationStorageCompletion)
    init(localization: String)
}

@objc public protocol RemoteLocalizationStorage: LocalizationStorage { }

@objc public protocol LocalLocalizationStorage: LocalizationStorage {
    var localizations: [String] { get set }
    var strings: [String: String] { get set }
    var plurals: [AnyHashable: Any] { get set }
}

@objc public protocol LocalizationProvider {
    init(localization: String, localStorage: LocalLocalizationStorage, remoteStorage: RemoteLocalizationStorage)
    var localStorage: LocalLocalizationStorage { get }
    var remoteStorage: RemoteLocalizationStorage { get }
    
    var localization: String { get set }
    var localizations: [String] { get }
    
    func deintegrate()
    func localizedString(for key: String) -> String?
    func key(for string: String) -> String?
    func values(for string: String, with format: String) -> [Any]?
}
