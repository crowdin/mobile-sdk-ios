//
//  MainViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 01/22/2019.
//  Copyright (c) 2019 Serhii Londar. All rights reserved.
//

import UIKit
import CrowdinSDK

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
            textLabel2.text = pineapplesCountUniversal(count: 0)
        }
    }
    @IBOutlet weak var textLabel3: UILabel! {
        didSet {
            textLabel3.text = String.localizedStringWithFormat(NSLocalizedString("test_with_format_key", comment: ""), "Parameter 21")
        }
    }
    @IBOutlet weak var presentDetailsButton: UIButton! {
        didSet {
            presentDetailsButton.setTitle(NSLocalizedString("details_present", comment: ""), for: .normal)
            presentDetailsButton.setTitle(NSLocalizedString("details_present_highlighted", comment: ""), for: .highlighted)
        }
    }
    @IBOutlet weak var pushDetailsButton: UIButton! {
        didSet {
            pushDetailsButton.setTitle(NSLocalizedString("details_push", comment: ""), for: .normal)
            pushDetailsButton.setTitle(NSLocalizedString("details_push_highlighted", comment: ""), for: .highlighted)
        }
    }
    
    private func pineapplesCountUniversal(count: UInt) -> String{
        let formatString : String = NSLocalizedString("johns pineapples count", comment: "Johns pineapples count string format to be found in Localized.stringsdict")
        let resultString1 : String = String.localizedStringWithFormat(formatString, count)
        return resultString1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("main_title", comment: "")
    }
    
    @objc func didDownloadLocalization() {
        print("!!!!!!!! Localization Updated !!!!!!!!!!!")
    }
    
    @IBAction func reloadUI(_ sender: AnyObject) {
        self.title = NSLocalizedString("main_title", comment: "")
        textLabel.text = NSLocalizedString("test_key", comment: "")
        textLabel1.text =  String.localizedStringWithFormat(NSLocalizedString("test_with_format_key", comment: ""), "Parameter")
        textLabel2.text = pineapplesCountUniversal(count: 10)
    }
    
    @IBAction func pushDetaildVC(_ sender: AnyObject) {
        let detailsVC = UIStoryboard(name: "DetailsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    @IBAction func presentDetaildVC(_ sender: AnyObject) {
        let detailsVC = UIStoryboard(name: "DetailsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        let nc = UINavigationController(rootViewController: detailsVC)
        self.navigationController?.present(nc, animated: true, completion: nil)
    }
}

