
//
//  StringsVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 2/18/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit
import CrowdinSDK

class StringsVC: BaseMenuVC {
    let crowdinSDKTester = CrowdinSDKTester(localization: CrowdinSDK.currentLocalization ?? "en")
    
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
			tableView.reloadData()
		}
	}
	
    var localizationKeys: [String] {
        return crowdinSDKTester.inSDKStringsKeys
    }
}

extension StringsVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return localizationKeys.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		let text = NSLocalizedString(localizationKeys[indexPath.row], comment: "")
        
		cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
		return cell
	}
}
