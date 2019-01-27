//
//  SettingsVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 1/27/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit
import CrowdinSDK

class SettingsVC: BaseMenuVC {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
        }
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        if section == 0 {
            label.text = NSLocalizedString("settings_in_bundle", comment: "")
        } else if section == 1 {
            label.text = NSLocalizedString("settings_in_sdk", comment: "")
        }
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return CrowdinSDK.inBundleLocalizations.count
        } else if section == 1 {
            return CrowdinSDK.inSDKLocalizations.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = CrowdinSDK.inBundleLocalizations[indexPath.row]
            guard let language = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String else { return cell }
            if !CrowdinSDK.enabled, CrowdinSDK.inBundleLocalizations[indexPath.row] == language {
                cell.accessoryType = .checkmark
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = CrowdinSDK.inSDKLocalizations[indexPath.row]
            if CrowdinSDK.enabled && CrowdinSDK.inSDKLocalizations[indexPath.row] == CrowdinSDK.currentLocalization  {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            CrowdinSDK.enabled = false
            let localization = CrowdinSDK.inBundleLocalizations[indexPath.row]
            UserDefaults.standard.set([localization], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            exit(0)
            // Set New bundle localization by setting language code in Pref's
        } else if indexPath.section == 1 {
            CrowdinSDK.enabled = true
            CrowdinSDK.setLocale(CrowdinSDK.inSDKLocalizations[indexPath.row])
            CrowdinSDK.refresh()
        }
        self.tableView.reloadData()
    }
}
