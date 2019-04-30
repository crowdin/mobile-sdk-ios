//
//  WebViewController.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/28/19.
//

import Foundation
import WebKit

class LoginWebViewController: WKWebView {
    var baseURL = "https://crowdin.com/login"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.load(URLRequest(url: URL(string: baseURL)!))
    }
}
