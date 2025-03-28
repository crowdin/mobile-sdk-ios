//
//  CrowdinProviderConfig.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/9/19.
//

import Foundation

@objcMembers public class CrowdinProviderConfig: NSObject {
    var hashString: String
    var sourceLanguage: String
    var organizationName: String?
    var minimumManifestUpdateInterval: TimeInterval
    public init(hashString: String, sourceLanguage: String, organizationName: String? = nil, minimumManifestUpdateInterval: TimeInterval = Constants.defaultMinimumManifestUpdateInterval) {
        self.hashString = hashString
        self.sourceLanguage = sourceLanguage
        self.organizationName = organizationName
        self.minimumManifestUpdateInterval = minimumManifestUpdateInterval
    }

    @available(*, deprecated, renamed: "init(hashString:sourceLanguage:)")
    public init(hashString: String, localizations: [String], sourceLanguage: String) {
        self.hashString = hashString
        self.sourceLanguage = sourceLanguage
        self.minimumManifestUpdateInterval = Constants.defaultMinimumManifestUpdateInterval
    }

    public override init() {
        guard let hashString = Bundle.main.crowdinDistributionHash else {
            fatalError("Please add CrowdinDistributionHash key to your Info.plist file")
        }
        self.hashString = hashString
        guard let crowdinSourceLanguage = Bundle.main.crowdinSourceLanguage else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.sourceLanguage = crowdinSourceLanguage
        self.minimumManifestUpdateInterval = Constants.defaultMinimumManifestUpdateInterval
    }
    public enum Constants {
        // New default minimum interval for manifest updates
        public static let defaultMinimumManifestUpdateInterval: TimeInterval = 15 * 60 // 15 minutes
    }
}
