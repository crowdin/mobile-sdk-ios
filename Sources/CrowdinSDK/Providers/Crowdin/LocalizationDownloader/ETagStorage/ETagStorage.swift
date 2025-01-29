//
//  ETagStorage.swift
//  BaseAPI
//
//  Created by Serhii Londar on 29.03.2020.
//

import Foundation

protocol AnyEtagStorage {
    init(localization: String)

    func save(etag: String?, for file: String)
    func etag(for file: String) -> String?

    func clear()
    func clear(for file: String)

    static func clear()
}
