//
//  PluralsVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 3/25/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation
import CrowdinSDK

class PluralsVC: BaseMenuVC {
    let crowdinSDKTester = CrowdinSDKTester(localization: CrowdinSDK.currentLocalization ?? "en")
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
    }
    
    var localizationKeys: [String] {
        return crowdinSDKTester.inSDKPluralsKeys
    }
}

extension PluralsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localizationKeys.count * 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var text: String
        let index = Int(indexPath.row / 5)
        let rule = indexPath.row % 5
        if rule == 0 {
            text = String.localizedStringWithFormat(NSLocalizedString(localizationKeys[index], comment: ""), 0, 100)
        } else if rule == 1 {
            text = String.localizedStringWithFormat(NSLocalizedString(localizationKeys[index], comment: ""), 1, 100)
        } else if rule == 2 {
            text = String.localizedStringWithFormat(NSLocalizedString(localizationKeys[index], comment: ""), 2, 100)
        } else if rule == 3 {
            text = String.localizedStringWithFormat(NSLocalizedString(localizationKeys[index], comment: ""), 3, 100)
        } else {
            text = String.localizedStringWithFormat(NSLocalizedString(localizationKeys[index], comment: ""), 100, 100)
        }
        
        cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
