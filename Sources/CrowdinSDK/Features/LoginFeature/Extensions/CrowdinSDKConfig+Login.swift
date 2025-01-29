//
//  CrowdinSDK+Login.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 8/16/19.
//

import Foundation

/// Extension that adds login configuration capabilities to CrowdinSDKConfig.
/// This extension allows you to configure authentication settings for the Crowdin SDK.
extension CrowdinSDKConfig {
    /// Static storage for login configuration
    private static var loginConfig: CrowdinLoginConfig?

    /// The login configuration for Crowdin SDK
    /// This property manages authentication settings including client ID, client secret,
    /// and organization name (for enterprise usage)
    var loginConfig: CrowdinLoginConfig? {
        get {
            return CrowdinSDKConfig.loginConfig
        }
        set {
            CrowdinSDKConfig.loginConfig = newValue
        }
    }

    /// Configures the SDK with login settings
    /// - Parameter loginConfig: The login configuration containing authentication details
    /// - Returns: The current CrowdinSDKConfig instance for chaining
    /// - Example:
    ///   ```swift
    ///   let config = CrowdinSDKConfig.config()
    ///       .with(loginConfig: CrowdinLoginConfig(
    ///           clientId: "your_client_id",
    ///           clientSecret: "your_client_secret",
    ///           organizationName: "your_organization")) // Optional, for enterprise
    ///   ```
    public func with(loginConfig: CrowdinLoginConfig) -> Self {
        self.loginConfig = loginConfig
        if let organizationName = loginConfig.organizationName {
            self.crowdinProviderConfig?.organizationName = organizationName
        }
        return self
    }

    /// Static storage for access token
    private static var accessToken: String?

    /// The access token used for authentication with Crowdin API
    /// This token is used to authorize requests to the Crowdin service
    var accessToken: String? {
        get {
            return CrowdinSDKConfig.accessToken
        }
        set {
            CrowdinSDKConfig.accessToken = newValue
        }
    }

    /// Configures the SDK with an access token for authentication
    /// - Parameter accessToken: The access token for Crowdin API authentication
    /// - Returns: The current CrowdinSDKConfig instance for chaining
    /// - Note: This authentication method have bigger priority than loginConfig, so in case both will be added token authentication will be used.
    /// - Example:
    ///   ```swift
    ///   let config = CrowdinSDKConfig.config()
    ///       .with(accessToken: "your_access_token")
    ///   ```
    public func with(accessToken: String) -> Self {
        Self.accessToken = accessToken
        return self
    }
}
