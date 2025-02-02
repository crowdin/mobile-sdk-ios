//
//  BrowserLoginFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/20/19.
//

#if os(iOS)
import UIKit
import SafariServices
#elseif os(macOS)
import AppKit
#endif
import Foundation

final class BrowserLoginFeature: NSObject, AnyLoginFeature {
    var config: CrowdinLoginConfig

    private var loginAPI: LoginAPI
#if os(iOS)
    fileprivate var safariVC: SFSafariViewController?
#endif

    init(hashString: String, organizationName: String?, config: CrowdinLoginConfig) {
        self.config = config
        self.loginAPI = LoginAPI(clientId: config.clientId, clientSecret: config.clientSecret, scope: config.scope, redirectURI: config.redirectURI, organizationName: organizationName)
        super.init()
        if self.hashString != hashString {
            self.logout()
        }
        self.hashString = hashString
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUnautorizedResponse), name: .CrowdinAPIUnautorizedNotification, object: nil)
    }

    var hashString: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "crowdin.hash.key")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "crowdin.hash.key") ?? ""
        }
    }

    var tokenExpirationDate: Date? {
        set {
            UserDefaults.standard.set(newValue, forKey: "crowdin.tokenExpirationDate.key")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.object(forKey: "crowdin.tokenExpirationDate.key") as? Date
        }
    }

    var tokenResponse: TokenResponse? {
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "crowdin.tokenResponse.key")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let data = UserDefaults.standard.data(forKey: "crowdin.tokenResponse.key") else { return nil }
            return try? JSONDecoder().decode(TokenResponse.self, from: data)
        }
    }

    var isLogined: Bool {
        return tokenResponse?.accessToken != nil && tokenResponse?.refreshToken != nil
    }

    var accessToken: String? {
        guard let tokenExpirationDate = tokenExpirationDate else { return nil }
        if tokenExpirationDate < Date() {
            if let refreshToken = tokenResponse?.refreshToken, let response = loginAPI.refreshTokenSync(refreshToken: refreshToken) {
                self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(response.expiresIn))
                self.tokenResponse = response
            } else {
                logout()
            }
        }
        return tokenResponse?.accessToken
    }

    var loginCompletion: (() -> Void)?  = nil
    var loginError: ((Error) -> Void)?  = nil

    func login(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        self.loginCompletion = completion
        self.loginError = error
        guard let url = URL(string: loginAPI.loginURLString) else {
            error(NSError(domain: "Unable to create URL for login", code: defaultCrowdinErrorCode, userInfo: nil))
            return
        }

        self.showWarningAlert(with: url)
    }

    func relogin(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        logout()
        login(completion: completion, error: error)
    }

    func logout() {
        logout(clearCreditials: false, completion: nil)
    }

    func logout(clearCreditials: Bool = false, completion: (() -> Void)? = nil) {
		tokenResponse = nil
		tokenExpirationDate = nil
        if clearCreditials {
            clearSafariViewServiceLibrary()
        }
        completion?()
    }

    func clearSafariViewServiceLibrary() {
        let fileManager = FileManager.default

        // Define the path to the Library directory in the SafariViewService container
        let safariViewServiceLibraryPath = "\(NSHomeDirectory())/SystemData/com.apple.SafariViewService/Library"

        do {
            // Get the list of files and directories in the SafariViewService Library path
            let items = try fileManager.contentsOfDirectory(atPath: safariViewServiceLibraryPath)

            // Loop through the items and remove each one
            for item in items {
                let fullPath = safariViewServiceLibraryPath + "/\(item)"
                try fileManager.removeItem(atPath: fullPath)
                print("Deleted item at path: \(fullPath)")
            }

            print("Successfully cleared SafariViewService Library.")

        } catch {
            print("Error clearing SafariViewService Library: \(error.localizedDescription)")
        }
    }

    func hadle(url: URL) -> Bool {
#if os(iOS)
        dismissSafariVC()
#endif
        let errorHandler = loginError ?? { _ in }
        let result = loginAPI.hadle(url: url, completion: { (tokenResponse) in
            self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(tokenResponse.expiresIn))
            self.tokenResponse = tokenResponse
            self.loginCompletion?()
        }, error: errorHandler)
        return result
	}

    @objc func receiveUnautorizedResponse() {
        // Try to refresh token.
        if let refreshToken = tokenResponse?.refreshToken, let response = loginAPI.refreshTokenSync(refreshToken: refreshToken) {
            self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(response.expiresIn))
            self.tokenResponse = response
        } else {
            logout()
        }
    }

    fileprivate func showWarningAlert(with url: URL) {
        let title = "CrowdinSDK"
        let message = "The Real-Time Preview and Screenshots features require Crowdin Authorization. You will now be redirected to the Crowdin login page."
        let okTitle = "OK"
        let cancelTitle = "Cancel"
#if os(iOS)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { _ in
            alert.cw_dismiss()
            self.showSafariVC(with: url)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .destructive, handler: { _ in
            alert.cw_dismiss()
        }))
        alert.cw_present()
#elseif os(macOS)
        guard let window = NSApplication.shared.windows.first else { return }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        let action = alert.addButton(withTitle: okTitle)
        alert.addButton(withTitle: cancelTitle)
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window) { response in
            if response.rawValue == 1000 {
                NSWorkspace.shared.open(url)
            }
        }
#endif
    }

#if os(iOS)
    fileprivate func showSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.cw_present()
        self.safariVC = safariVC
    }

    fileprivate func dismissSafariVC() {
        safariVC?.cw_dismiss()
        safariVC = nil
    }
#endif

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

#if os(iOS)
extension BrowserLoginFeature: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismissSafariVC()
    }
}
#endif
