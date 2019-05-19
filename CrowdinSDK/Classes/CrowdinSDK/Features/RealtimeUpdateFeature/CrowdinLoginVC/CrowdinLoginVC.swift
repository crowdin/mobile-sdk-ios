//
//  CrowdinLoginVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/29/19.
//

import Foundation

class CrowdinLoginVC: UIViewController {
    var baseURL = "https://crowdin.com/login"
    var completion: ((_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void)? = nil
    
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
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let userAgent = webView.request?.allHTTPHeaderFields?["User-Agent"] else { return }
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        for cookie in cookies {
            if cookie.name == "csrf_token" {
                self.completion?(cookie.value, userAgent, cookies)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
