//
//  ETagStorage.swift
//  BaseAPI
//
//  Created by Serhii Londar on 29.03.2020.
//

import Foundation

class ETagStorage {
    let defaults = UserDefaults.standard
    
    static let shared = ETagStorage()
    
    fileprivate enum Strings: String {
        case CrowdinETagsKey
    }
    
    var etags: [String: String] {
        get {
            return UserDefaults.standard.object(forKey: Strings.CrowdinETagsKey.rawValue) as? [String: String] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Strings.CrowdinETagsKey.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: Strings.CrowdinETagsKey.rawValue)
        UserDefaults.standard.synchronize()
    }
}
