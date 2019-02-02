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
            textField.placeholder =  NSLocalizedString("details_textfield_placeholder", comment: "")
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
            reloadUIButton.setTitle(NSLocalizedString("main_reload_ui_button", comment: ""), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("details_title", comment: "")
    }
    
    
    @IBAction func reloadUI(_ sender: AnyObject) {
        CrowdinSDK.reloadUI()
    }
}
