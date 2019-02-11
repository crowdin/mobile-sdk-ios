//
//  NSDictionary+ReadWrite.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/10/19.
//

import Foundation

extension NSDictionary: ReadWrite {
    func save(_ path: String) {
        self.write(toFile: path, atomically: true)
    }
    
    static func read(from path: String) -> Self? {
        return self.init(contentsOfFile: path)
    }
}
