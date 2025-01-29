//
//  UserDefaultsETagStorage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.05.2022.
//

import Foundation

/// Old implementation. Not used.
final class UserDefaultsETagStorage: AnyEtagStorage {
    let defaults = UserDefaults.standard
    let localization: String

    fileprivate enum Strings: String {
        case CrowdinETagsKey
    }

    init(localization: String) {
        self.localization = localization
    }

    func save(etag: String?, for file: String) {
        var map = UserDefaults.standard.object(forKey: Strings.CrowdinETagsKey.rawValue) as? [String: [String: String]] ?? [String: [String: String]]()

        var etags = map[localization] ?? [:]
        etags[file] = etag
        map[localization] = etags

        UserDefaults.standard.set(map, forKey: Strings.CrowdinETagsKey.rawValue)
        UserDefaults.standard.synchronize()
    }

    func etag(for file: String) -> String? {
        let map = UserDefaults.standard.object(forKey: Strings.CrowdinETagsKey.rawValue) as? [String: [String: String]] ?? [String: [String: String]]()
        return map[localization]?[file]
    }

    func clear(for file: String) {
        var map = UserDefaults.standard.object(forKey: Strings.CrowdinETagsKey.rawValue) as? [String: [String: String]] ?? [String: [String: String]]()
        map[localization]?[file] = nil
        UserDefaults.standard.set(map, forKey: Strings.CrowdinETagsKey.rawValue)
        UserDefaults.standard.synchronize()
    }

    func clear() {
        var map = UserDefaults.standard.object(forKey: Strings.CrowdinETagsKey.rawValue) as? [String: [String: String]] ?? [String: [String: String]]()
        map[localization] = nil
        UserDefaults.standard.set(map, forKey: Strings.CrowdinETagsKey.rawValue)
        UserDefaults.standard.synchronize()
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Strings.CrowdinETagsKey.rawValue)
        UserDefaults.standard.synchronize()
    }
}
