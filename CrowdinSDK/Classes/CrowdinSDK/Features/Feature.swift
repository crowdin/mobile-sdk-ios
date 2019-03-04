//
//  Feature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

protocol Feature {
    var enabled: Bool { get set }
    init(enabled: Bool)
}
