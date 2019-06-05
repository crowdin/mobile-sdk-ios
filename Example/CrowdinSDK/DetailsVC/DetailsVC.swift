//
//  DetailsVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 1/26/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit
import CrowdinSDK

class DetailsVC: UIViewController {
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = NSLocalizedString("details_label", comment: "")
        }
    }
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle(NSLocalizedString("details_button", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var textField: UITextField! {
        didSet {
//            textField.placeholder =  NSLocalizedString("details_textfield_placeholder", comment: "")
            textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("details_textfield_placeholder", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(NSLocalizedString("details_segmentedControl_0", comment: ""), forSegmentAt: 0)
            segmentedControl.setTitle(NSLocalizedString("details_segmentedControl_1", comment: ""), forSegmentAt: 1)
        }
    }
    @IBOutlet weak var reloadUIButton: UIButton! {
        didSet {
            let string = "test_with_format_key".cw_localized(with: ["Test parameter"])
            let normalAttributedTitle = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : UIColor.yellow])
            reloadUIButton.setAttributedTitle(normalAttributedTitle, for: .normal)
            let highlightedAttributedTitle = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : UIColor.green])
            reloadUIButton.setAttributedTitle(highlightedAttributedTitle, for: .highlighted)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("details_title", comment: "")
    }
    
    
    @IBAction func reloadUI(_ sender: AnyObject) {
        
    }
}
