//
//  UIImage.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

extension UIImage {
    func save(_ path: String) throws {
       try self.pngData()?.write(to: URL(fileURLWithPath: path))
    }
}
