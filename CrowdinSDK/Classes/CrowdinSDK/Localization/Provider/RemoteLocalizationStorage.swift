//
//  RemoteLocalizationStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/3/19.
//

import Foundation

@objc public protocol RemoteLocalizationStorageProtocol: LocalizationStorageProtocol {
    var name: String { get set }
}
