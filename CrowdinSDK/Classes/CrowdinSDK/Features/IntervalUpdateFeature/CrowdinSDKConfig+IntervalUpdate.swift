//
//  CrowdinSDKConfig+IntervalUpdate.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDKConfig {
    private static var intervalUpdatesEnabled: Bool = false
    private static var intervalUpdatesInterval: TimeInterval? = nil
    // Interval updates
    var intervalUpdatesInterval: TimeInterval? {
        get {
            return CrowdinSDKConfig.intervalUpdatesInterval
        }
        set {
            CrowdinSDKConfig.intervalUpdatesInterval = newValue
        }
    }
    // Realtime updates
    var intervalUpdatesEnabled: Bool {
        get {
            return CrowdinSDKConfig.intervalUpdatesEnabled
        }
        set {
            CrowdinSDKConfig.intervalUpdatesEnabled = newValue
        }
    }
    
    public func with(intervalUpdatesEnabled: Bool, interval: TimeInterval?) -> Self {
        self.intervalUpdatesEnabled = intervalUpdatesEnabled
        self.intervalUpdatesInterval = interval
        return self
    }
}
