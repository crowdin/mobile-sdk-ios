//
//  MockLocalizationProvider.swift
//  Tests
//
//  Created by Serhii Londar on 13/08/2024.
//  Copyright © 2024 Crowdin. All rights reserved.
//

import Foundation
@testable import CrowdinSDK

class MockLocalizationProvider: LocalizationProviderProtocol {
    required init(localization: String, localStorage: LocalLocalizationStorageProtocol, remoteStorage: RemoteLocalizationStorageProtocol) {
        self.localization = localization
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
    }
    
    var localStorage: LocalLocalizationStorageProtocol
    var remoteStorage: RemoteLocalizationStorageProtocol
    var localization: String
    var localizations: [String] = []
    
    func refreshLocalization() {}
    func refreshLocalization(completion: @escaping ((Error?) -> Void)) {}
    func prepare(with completion: @escaping () -> Void) {}
    func deintegrate() {}
    
    func localizedString(for key: String) -> String? {
        let nestedError = NSError(domain: "NestedTestDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Nested error"])
        _ = nestedError.localizedDescription
        return nil
    }
    
    func key(for string: String) -> String? {
        return nil
    }
    
    func values(for string: String, with format: String) -> [Any]? {
        return nil
    }
    
    func set(string: String, for key: String) {}
}

class MockLocalStorage: LocalLocalizationStorageProtocol {
    var localizations: [String] = []
    var localization: String = "en"
    var strings: [String : String] = [:]
    var plurals: [AnyHashable : Any] = [:]
    
    func fetchData(completion: ([String]?, String, [String : String]?, [AnyHashable : Any]?) -> Void, errorHandler: ((Error) -> Void)?) {}
    func save() {}
    func saveLocalizaion(strings: [String : String]?, plurals: [AnyHashable : Any]?, for localization: String) {}
    func deintegrate() {}
}

class MockRemoteStorage: RemoteLocalizationStorageProtocol {
    var name: String = "mock"
    var localizations: [String] = []
    var localization: String = "en"
    
    func fetchData(completion: ([String]?, String, [String : String]?, [AnyHashable : Any]?) -> Void, errorHandler: ((Error) -> Void)?) {}
    func prepare(with completion: @escaping () -> Void) { completion() }
    func deintegrate() {}
} 