//
//  CrowdinSDK+Login.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

extension CrowdinSDK {
	class func setupLogin() {
		guard let config = CrowdinSDK.config else { return }
		guard let loginConfig = config.loginConfig else { return }
		LoginFeature.configureWith(with: loginConfig)
	}
}
