//
//  CrowdinSDK+IntervalUpdate.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDK {
    class func initializeIntervalUpdateFeature() {
        guard let config = CrowdinSDK.config else { return }
        if config.intervalUpdatesEnabled, let interval = config.intervalUpdatesInterval {
            IntervalUpdateFeature.shared = IntervalUpdateFeature(interval: interval)
            IntervalUpdateFeature.shared?.start()
        }
    }
}
