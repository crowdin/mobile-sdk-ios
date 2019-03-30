//
//  PluralsCell.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 3/27/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit

class PluralsCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var keyValueLabel: UILabel!
    @IBOutlet weak var stringLabel: UILabel!
    @IBOutlet weak var stringValueLabel: UILabel!
    @IBOutlet weak var valuesLabel: UILabel!
    @IBOutlet weak var valuesValueTextField: UITextField! {
        didSet {
            valuesValueTextField.delegate = self
        }
    }
}

extension PluralsCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let arguments = textField.text?.components(separatedBy: ",").compactMap({ $0.trimmingCharacters(in: CharacterSet.whitespaces) }) else { return }
        let intArguments = arguments.map({ UInt($0) ?? 0 })
        stringValueLabel.text = keyValueLabel.text?.localized(with: intArguments)        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
