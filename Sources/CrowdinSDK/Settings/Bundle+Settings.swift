//
//  Bundle+Resources.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/23/19.
//

import Foundation

extension Bundle {
    class var resourceBundle: Bundle {
        let moduleSelector = Selector(stringLiteral: "module")
        if Bundle.responds(to: moduleSelector) {
            // swiftlint:disable force_cast
            let bundle = Bundle.perform(moduleSelector)
            return bundle?.takeRetainedValue() as! Bundle
        }
        return Bundle(for: SettingsView.self)
    }
}
