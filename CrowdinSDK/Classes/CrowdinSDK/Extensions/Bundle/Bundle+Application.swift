//
//  Bundle+Application.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/23/19.
//

import Foundation

extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }
    
    var bundleId: String {
        return bundleIdentifier!
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    
    var launchStoryboardName: String? {
        return infoDictionary?["UILaunchStoryboardName"] as? String
    }
    
    /// Localization native development region
    var developmentRegion: String? {
        return infoDictionary?["CFBundleDevelopmentRegion"] as? String
    }
}
