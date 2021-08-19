//
//  Bundle+Resources.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/23/19.
//

import Foundation

extension Bundle {
    class var resourceBundle: Bundle {
        // swiftlint:disable force_unwrapping
        if Bundle.responds(to: Selector(("module"))) {
            return Bundle.perform(Selector(("module"))) as! Bundle
        }
        return Bundle(for: SettingsView.self)
    }
}
