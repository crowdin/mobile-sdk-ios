
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
    let crowdinSDKTester = CrowdinProviderTester(localization: CrowdinSDK.currentLocalization ?? "en")
    
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
            tableView.tableFooterView = UIView(frame: CGRect.zero)
		}
	}
	
    var localizationKeys: [String] {
        return crowdinSDKTester.inSDKStringsKeys
    }
    
    var filteredResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "strings_title".localized
        
        self.filteredResults = localizationKeys
        tableView.reloadData()
    }
}

extension StringsVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredResults.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "StringsCell") as! StringsCell
        let key = filteredResults[indexPath.row]
        cell.keyValueLabel.text = key
        cell.stringValueLabel.text = NSLocalizedString(key, comment: "")
		return cell
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return -1
    }
}

extension StringsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = searchText.isEmpty ? self.localizationKeys : self.localizationKeys.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
