
//
//  FormatedStringsVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 2/18/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit

class FormatedStringsVC: BaseMenuVC {
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
			tableView.reloadData()
		}
	}
	
	var localizationKeys: [String] =
		[
			"test_with_format_key",
			"test_format_key_with_1_parameter",
			"test_format_key_with_2_parameters",
			"test_format_key_with_3_parameters"
		]
	var localizationParameters: [[String]] = [
		["param"],
		["param"],
		["param", "param 12"],
		["param", "param 2", "param 3"]
	]
}

extension FormatedStringsVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return localizationKeys.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		let text = String(format: NSLocalizedString(localizationKeys[indexPath.row], comment: ""), arguments: localizationParameters[indexPath.row])
		cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
		return cell
	}
}
