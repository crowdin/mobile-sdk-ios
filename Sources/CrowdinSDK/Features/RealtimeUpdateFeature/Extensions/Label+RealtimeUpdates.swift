//
//  Label+RealtimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/5/19.
//

#if os(iOS)
import UIKit
#endif
import Foundation

extension CWLabel {
    /// Subscribe Label for realtime updates if it has localization key and realtime updates feature enabled.
    @objc func subscribeForRealtimeUpdates() {
        if self.localizationKey != nil {
            RealtimeUpdateFeature.shared?.subscribe(control: self)
        }
    }

    /// Unsubscribe Label for realtime updates.
    @objc func unsubscribeForRealtimeUpdates() {
        RealtimeUpdateFeature.shared?.unsubscribe(control: self)
    }
}
