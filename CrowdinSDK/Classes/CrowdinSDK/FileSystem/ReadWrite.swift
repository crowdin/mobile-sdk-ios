//
//  ReadWrite.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/10/19.
//

import Foundation

protocol ReadWrite {
    func save(_ path: String)
    static func read(from path: String) -> Self?
}
