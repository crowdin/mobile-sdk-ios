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
            self.text = key.localized(with: values)
        } else if let key = self.localizationKey {
            self.text = key.localized
        }
    }
}

extension UIButton: Refreshable {
    func refresh() {
        UIControl.State.all.forEach { (state) in
            guard let key = self.localizationKeys?[state.rawValue] else { return }
            if let values = self.localizationValues?[state.rawValue] as? [CVarArg] {
                self.setTitle(key.localized(with: values), for: state)
            } else {
                self.setTitle(key.localized, for: state)
            }
        }
    }
}
