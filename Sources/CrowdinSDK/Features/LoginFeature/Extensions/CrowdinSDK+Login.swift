//
//  CrowdinSDK+Login.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

extension CrowdinSDK {
    static var loginFeature: AnyLoginFeature?

	class func setupLogin() {
        if let accessToken = config.accessToken {
            loginFeature = AccessTokenLoginFeature(accessToken: accessToken)
            CrowdinLogsCollector.shared.add(log: .info(with: "Login configured with access token."))
        } else if let config = CrowdinSDK.config, let loginConfig = config.loginConfig, let hash = config.crowdinProviderConfig?.hashString {
            loginFeature = BrowserLoginFeature(hashString: hash, organizationName: config.crowdinProviderConfig?.organizationName, config: loginConfig)
            CrowdinLogsCollector.shared.add(log: .info(with: "Login configured with browser login."))
        } else {
            CrowdinLogsCollector.shared.add(log: .error(with: "Login feature isn't configured."))
        }
	}

    public class func login(completion: (() -> Void)?, failure: ((Error) -> Void)?) {
        loginFeature?.login(completion: completion ?? { }, error: failure ?? { _ in })
    }

    public class func logout(clearCreditials: Bool, completion: (() -> Void)?) {
        loginFeature?.logout(clearCreditials: clearCreditials, completion: completion)
    }

    public class var loggedIn: Bool {
        Self.loginFeature?.isLogined ?? false
    }

    @discardableResult
    public class func handle(url: URL) -> Bool {
        return CrowdinSDK.loginFeature?.hadle(url: url) ?? false
    }
}
