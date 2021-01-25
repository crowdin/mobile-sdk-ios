//
//  SettingsVC.swift
//  AppleReminders
//
//  Created by Serhii Londar on 25.12.2020.
//  Copyright © 2020 Josh R. All rights reserved.
//

import UIKit
import CrowdinSDK

class SettingsVC: UITableViewController {
    let localizations = CrowdinSDK.allAvalaibleLocalizations
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(cancelBtnTapped))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        self.tableView.reloadData()
    }
    
    @objc func cancelBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Language".localized
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localizations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")!
        cell.textLabel?.text = localizations[indexPath.row]
        cell.accessoryType = CrowdinSDK.currentLocalization == localizations[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let localization = localizations[indexPath.row]
        CrowdinSDK.enableSDKLocalization(true, localization: localization)
        self.tableView.reloadData()
    }
}
