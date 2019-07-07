//
//  CrowdinSDKConfig+RealtimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDKConfig {
    private static var reatimeUpdatesEnabled: Bool = false
    // Realtime updates
    var reatimeUpdatesEnabled: Bool {
        get {
            return CrowdinSDKConfig.reatimeUpdatesEnabled
        }
        set {
            CrowdinSDKConfig.reatimeUpdatesEnabled = newValue
        }
    }
    
    public func with(reatimeUpdatesEnabled: Bool) -> Self {
        self.reatimeUpdatesEnabled = reatimeUpdatesEnabled
        return self
    }
}
