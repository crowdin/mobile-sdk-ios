//
//  BaseMenuVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 1/26/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit

private extension Selector {
    static let onMenuOpen = #selector(BaseMenuVC.onMenuOpen)
}

class BaseMenuVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItem.Style.done, target: self, action: .onMenuOpen)
    }
    
    @objc func onMenuOpen() {
        self.panel?.openLeft(animated: true)
    }
}


class BaseMenuTableVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItem.Style.done, target: self, action: .onMenuOpen)
    }
    
    @objc func onMenuOpen() {
        self.panel?.openLeft(animated: true)
    }
}
