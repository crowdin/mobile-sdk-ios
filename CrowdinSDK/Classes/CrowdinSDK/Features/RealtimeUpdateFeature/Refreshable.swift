//
//  Refreshable.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

protocol Refreshable: NSObjectProtocol {
    func refresh()
}

extension UILabel: Refreshable {
    func refresh() {
        if let key = self.localizationKey, let values = self.localizationValues as? [CVarArg] {
            self.text = String(format: NSLocalizedString(key, comment: ""), arguments: values)
        } else if let key = self.localizationKey {
            self.text = NSLocalizedString(key, comment: "")
        }
        // TODO: Check whether we need this for force redrawing.
        self.setNeedsDisplay()
    }
}

extension UIButton: Refreshable {
    func refresh() {
        // TODO: Plurals and formated string support.
        if let key = self.localizationKeys?[self.state.rawValue] {
            self.setTitle(NSLocalizedString(key, comment: ""), for: self.state)
        }
    }
}
