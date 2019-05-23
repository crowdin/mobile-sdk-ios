//
//  Refreshable.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

protocol Refreshable: NSObjectProtocol {
    var key: String? { get }
    func refresh(text: String)
    func refresh()
}

extension UILabel: Refreshable {
    func refresh(text: String) {
        if let values = self.localizationValues as? [CVarArg] {
            let newText = String(format: text, arguments: values)
            self.original_setText(newText)
        } else {
            self.original_setText(text)
        }
    }
    
    var key: String? {
        return self.localizationKey
    }
    
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
    func refresh(text: String) {
        if let values = self.localizationValues?[state.rawValue] as? [CVarArg] {
            let newText = String(format: text, arguments: values)
            self.original_setTitle(newText, for: self.state)
        } else {
            self.original_setTitle(text, for: self.state)
        }
    }
    
    var key: String? {
        return self.localizationKeys?[state.rawValue]
    }
    
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
