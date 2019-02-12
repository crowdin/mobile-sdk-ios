//
//  MainViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 01/22/2019.
//  Copyright (c) 2019 Serhii Londar. All rights reserved.
//

import UIKit

class MainViewController: BaseMenuVC {
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = NSLocalizedString("test_key", comment: "")
        }
    }
    @IBOutlet weak var textLabel1: UILabel! {
        didSet {
            textLabel1.text = String.localizedStringWithFormat(NSLocalizedString("test_with_format_key", comment: ""), "Parameter")
        }
    }
    @IBOutlet weak var textLabel2: UILabel! {
        didSet {
            textLabel2.text = R.string.localizable.johnsPineapplesCount(v1_pineapples_count: 12)
            //textLabel2.text = pineapplesCountUniversal(count: 2, count2: 12)
        }
    }
    @IBOutlet weak var reloadUIButton: UIButton! {
        didSet {
            reloadUIButton.setTitle(NSLocalizedString("main_reload_ui_button", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var showDetailsButton: UIButton! {
        didSet {
            showDetailsButton.setTitle(NSLocalizedString("main_show_details_button", comment: ""), for: .normal)
        }
    }
    
    private func pineapplesCountUniversal(count: UInt, count2: UInt) -> String{
        let formatString : String = NSLocalizedString("johns pineapples count", comment: "Johns pineapples count string format to be found in Localized.stringsdict")
        let resultString1 : String = String.localizedStringWithFormat(formatString, count)
        return resultString1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("main_title", comment: "")
    }
    
    @IBAction func reloadUI(_ sender: AnyObject) {
        self.title = NSLocalizedString("main_title", comment: "")
        textLabel.text = NSLocalizedString("test_key", comment: "")
        textLabel1.text =  String.localizedStringWithFormat(NSLocalizedString("test_with_format_key", comment: ""), "Parameter")
    }
    
    @IBAction func showDetaildVC(_ sender: AnyObject) {
        let detailsVC = UIStoryboard(name: "DetailsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}

