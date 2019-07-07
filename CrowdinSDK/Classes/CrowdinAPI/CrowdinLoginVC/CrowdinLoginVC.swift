//
//  CrowdinLoginVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/29/19.
//

import Foundation

extension Bundle {
    class var loginBundle: Bundle {
        // swiftlint:disable force_unwrapping
        let assetPath = Bundle(for: CrowdinLoginVC.self).resourcePath!
        return Bundle(path: assetPath + String.pathDelimiter + "CrowdinSDKLogin.bundle")!
    }
}

class CrowdinLoginVC: UIViewController {    
    var baseURL = "https://crowdin.com/login"
    var window: UIWindow?
    
    var error: ((_ error: Error) -> Void)? = nil
    var completion: ((_ csrfToken: String, _ userAgent: String, _ cookies: [HTTPCookie]) -> Void)? = nil
    
    var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    func present() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: self)
        window?.makeKeyAndVisible()
    }
    
    @objc func dismiss() {
        self.window?.resignKey()
        self.window?.isHidden = true
        self.window = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView)
        guard let url = URL(string: baseURL) else { return }
        webView.loadRequest(URLRequest(url: url))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CrowdinLoginVC.doneButtonPressed))
    }
    
    @objc func doneButtonPressed() {
        self.dismiss()
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
