//
//  UIImage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

extension UIImage: ReadWrite {
    static func read(from path: String) -> Self? {
        return self.init(contentsOfFile: path)
    }
    
    func save(_ path: String) {
        try? self.pngData()?.write(to: URL(fileURLWithPath: path))
    }
}
