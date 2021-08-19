//
//  Bundle+Resources.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/23/19.
//

import Foundation

extension Bundle {
    class var resourceBundle: Bundle {
        if Bundle.responds(to: Selector(("module"))) {
            // swiftlint:disable force_cast
            let bundle = Bundle.perform(Selector(("module")))
            return bundle?.takeRetainedValue() as! Bundle
        }
        return Bundle(for: SettingsView.self)
    }
}
