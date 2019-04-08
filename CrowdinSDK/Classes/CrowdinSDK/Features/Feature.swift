//
//  Feature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

protocol Feature {
    static var shared: Self? { get set }
    static var enabled: Bool { get set }
}
