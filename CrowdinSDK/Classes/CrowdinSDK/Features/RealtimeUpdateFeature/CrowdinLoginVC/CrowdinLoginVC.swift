//
//  CrowdinLoginVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/29/19.
//

import Foundation

class CrowdinLoginVC: UIViewController {
    var baseURL = "https://crowdin.com/login"
    var csrfTokenCompletion: ((String) -> Void)? = nil
    
    @IBOutlet var webView: UIWebView! {
        didSet {
            webView.delegate = self
            guard let url = URL(string: baseURL) else { return }
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    static var instantiateVC: CrowdinLoginVC? {
        let storyboard = UIStoryboard(name: "CrowdinLoginVC", bundle: Bundle(for: CrowdinLoginVC.self))
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CrowdinLoginVC") as? CrowdinLoginVC else { return nil }
        return vc
    }
}

extension CrowdinLoginVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        for cookie in cookies {
            if cookie.name == "csrf_token" {
                print(cookie.value)
                self.csrfTokenCompletion?(cookie.value)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
