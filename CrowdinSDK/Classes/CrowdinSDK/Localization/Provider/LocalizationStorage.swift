//
//  LocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/3/19.
//

import Foundation

public typealias LocalizationStorageCompletion = (_ localizations: [String]?, _ strings: [String: String]?, _ plurals: [AnyHashable: Any]?) -> Void

@objc public protocol LocalizationStorageProtocol {
    var localization: String { get set }
    func fetchData(completion: @escaping LocalizationStorageCompletion)
}
