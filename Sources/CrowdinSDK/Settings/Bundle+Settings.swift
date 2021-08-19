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
        return Bundle(for: SettingsView.self)
    }
}
