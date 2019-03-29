//
//  LocalizationUpdateViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

class LocalizationUpdateVC: UIViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    var control: UILabel!
    
    @IBOutlet var localizationKeyLabel: UILabel!
    @IBOutlet var localizationKeyTextField: UITextField! {
        didSet {
            localizationKeyTextField.text = control.localizationKey
        }
    }
    @IBOutlet var localizationStringLabel: UILabel!
    @IBOutlet var localizationStringTextField: UITextField! {
        didSet {
            localizationStringTextField.text = control.text
        }
    }
    @IBOutlet var localizationValuesLabel: UILabel!
    @IBOutlet var localizationValuesTextField: UITextField! {
        didSet {
            if let values = control.localizationValues {
                var text = ""
                values.forEach({ text += String(describing: $0) + ", " })
                _ = text.removeLast()
                localizationValuesTextField.text = text
            } else {
                localizationValuesLabel.isHidden = true
                localizationValuesTextField.isHidden = true
            }
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
