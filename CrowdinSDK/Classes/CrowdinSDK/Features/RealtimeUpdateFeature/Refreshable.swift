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
        guard let key = self.localizationKey else { return }
        if let values = self.localizationValues as? [CVarArg] {
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
        UIControl.State.all.forEach { (state) in
            guard let key = self.localizationKeys?[state.rawValue] else { return }
            if let values = self.localizationValues?[state.rawValue] as? [CVarArg] {
                self.setTitle( String(format: NSLocalizedString(key, comment: ""), arguments: values), for: state)
            } else {
                self.setTitle(NSLocalizedString(key, comment: ""), for: state)
            }
        }
        // TODO: Check whether we need this for force redrawing.
        self.setNeedsDisplay()
    }
}
