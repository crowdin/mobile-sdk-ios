//
//  MenuVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 1/26/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit
import FAPanels
import FileBrowser
import CrowdinSDK

class MenuVC: UIViewController {
    @IBOutlet weak var mainButton: UIButton! {
        didSet {
            mainButton.setTitle(NSLocalizedString("menu_main_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var explorerButton: UIButton! {
        didSet {
            explorerButton.setTitle(NSLocalizedString("menu_explorer_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.setTitle(NSLocalizedString("menu_settings_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var stringsButton: UIButton! {
        didSet {
            stringsButton.setTitle(NSLocalizedString("menu_strings_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var pluralsButton: UIButton! {
        didSet {
            pluralsButton.setTitle(NSLocalizedString("menu_plurals_button_title", comment: ""), for: .normal)
        }
    }
    
    @IBAction func mainButtonPressed(_ sender: AnyObject) {
        if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is MainViewController {
            panel?.closeLeft()
        } else {
            let mainVC = UIStoryboard(name: "MainViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            let mainNC = UINavigationController(rootViewController: mainVC)
            _ = panel?.center(mainNC)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func explorerButtonPressed(_ sender: AnyObject) {
        if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is FileBrowser {
            panel?.closeLeft()
        } else {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let fileExplorer = FileBrowser(initialPath: documentsUrl, allowEditing: true)
            _ = self.panel?.center(fileExplorer)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is SettingsVC {
            panel?.closeLeft()
        } else {
            let settingsVC = UIStoryboard(name: "SettingsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            let settingsNC = UINavigationController(rootViewController: settingsVC)
            _ = panel?.center(settingsNC)
        }
    }
	
	@IBAction func stringsButtonPressed(_ sender: AnyObject) {
		if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is StringsVC {
			panel?.closeLeft()
		} else {
			let formatedStringsVC = UIStoryboard(name: "StringsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "StringsVC") as! StringsVC
			let formatedStringsNC = UINavigationController(rootViewController: formatedStringsVC)
			_ = panel?.center(formatedStringsNC)
		}
	}
    
    @IBAction func pluralsButtonPressed(_ sender: AnyObject) {
        if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is PluralsVC {
            panel?.closeLeft()
        } else {
            let pluralsVC = UIStoryboard(name: "PluralsVC", bundle: Bundle.main).instantiateViewController(withIdentifier: "PluralsVC") as! PluralsVC
            let pluralsNC = UINavigationController(rootViewController: pluralsVC)
            _ = panel?.center(pluralsNC)
        }
    }
	
	func show(vc: UIViewController) {
		
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadUI() {
        mainButton.setTitle(NSLocalizedString("menu_main_button_title", comment: ""), for: .normal)
        explorerButton.setTitle(NSLocalizedString("menu_explorer_button_title", comment: ""), for: .normal)
        settingsButton.setTitle(NSLocalizedString("menu_settings_button_title", comment: ""), for: .normal)
        stringsButton.setTitle(NSLocalizedString("menu_strings_button_title", comment: ""), for: .normal)
        pluralsButton.setTitle(NSLocalizedString("menu_plurals_button_title", comment: ""), for: .normal)
    }
}
