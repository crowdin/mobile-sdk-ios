//
//  Bundle+Resources.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/23/19.
//

import Foundation

extension Bundle {
    enum Selectors: Selector {
        case module
    }

    class var resourceBundle: Bundle {
        if Bundle.responds(to: Selectors.module.rawValue) {
            let bundle = Bundle.perform(Selectors.module.rawValue)
            // swiftlint:disable force_cast
            return bundle?.takeRetainedValue() as! Bundle
        }
        
        return Bundle(for: SettingsView.self)
    }
}
