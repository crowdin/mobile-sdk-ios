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

class MenuVC: UIViewController {
    @IBOutlet weak var mainButton: UIButton! {
        didSet {
            mainButton.setTitle(NSLocalizedString("menu_main_button_title", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var firebaseButton: UIButton! {
        didSet {
            firebaseButton.setTitle(NSLocalizedString("menu_firebase_button_title", comment: ""), for: .normal)
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
    
    @IBAction func mainButtonPressed(_ sender: AnyObject) {
        if let nc = panel?.center as? UINavigationController, nc.viewControllers.first is MainViewController {
            panel?.closeLeft()
        } else {
            let mainVC = UIStoryboard(name: "MainViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            let mainNC = UINavigationController(rootViewController: mainVC)
            _ = panel?.center(mainNC)
        }
    }
    
    @IBAction func firebaseButtonPressed(_ sender: AnyObject) {
        FireTiny.shared.getData(nil) { (data) in
            if let data = data {
                switch FireTiny.shared.typeOf(FirebaseData: data) {
                case .isArray, .isDictionary:
                    let vc : TableViewController = TableViewController()
                    vc.data = data
                    vc.address = NSURL.init(string: "/") as URL?
                    
                    let nc = UINavigationController(rootViewController: vc)
                    _ = self.panel?.center(nc)
                default:
                    let vc : ObjectViewController = ObjectViewController()
                    vc.data = data
                    
                    let nc = UINavigationController(rootViewController: vc)
                    _ = self.panel?.center(nc)
                }
            }
        }
    }
    
    @IBAction func explorerButtonPressed(_ sender: AnyObject) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let fileExplorer = FileBrowser(initialPath: documentsUrl, allowEditing: true)
        _ = self.panel?.center(fileExplorer)
    }
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        
    }
    
}
