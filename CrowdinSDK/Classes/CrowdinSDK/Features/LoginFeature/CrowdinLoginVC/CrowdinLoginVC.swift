//
//  CrowdinLoginVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/29/19.
//

import Foundation
import SafariServices

class CrowdinLoginVC: UIViewController {    
    var baseURL = "https://crowdin.com/login"
    var window: UIWindow?
    
    var error: ((_ error: Error) -> Void)? = nil
    var completion: ((_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void)? = nil
    
    @IBOutlet var webView: UIWebView! {
        didSet {
            webView.delegate = self
            guard let url = URL(string: baseURL) else { return }
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    func present() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = self
        window?.makeKeyAndVisible()
    }
    
    func dismiss() {
        self.window?.resignKey()
        self.window?.isHidden = true
        self.window = nil
    }
    
    static var instantiateVC: CrowdinLoginVC? {
        let storyboard = UIStoryboard(name: "CrowdinLoginVC", bundle: Bundle.resourceBundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CrowdinLoginVC") as? CrowdinLoginVC else { return nil }
        return vc
    }
}

extension CrowdinLoginVC: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.error?(error)
        self.dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let userAgent = webView.request?.allHTTPHeaderFields?["User-Agent"] else { return }
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        for cookie in cookies {
            if cookie.name == "csrf_token" {
                self.completion?(cookie.value, userAgent, cookies)
                self.dismiss()
            }
        }
    }
}
