//
//  CrowdinControl.swift
//
//
//  Created by Serhii Londar on 23.07.2022.
//

import Foundation

protocol CrowdinControl {
    var localizationKey: String? { get }
    var localizationValues: [Any]? { get }

    static func swizzle()
    static func unswizzle()

    static var isSwizzled: Bool { get }
}
