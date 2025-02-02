//
//  UIButton+RealtimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/5/19.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIButton {
    /// Subscribe UIButton for realtime updates if it has at least one localization key for any state and realtime updates feature enabled.
    @objc func subscribeForRealtimeUpdates() {
        if self.localizationKeys != nil {
            RealtimeUpdateFeature.shared?.subscribe(control: self)
        }
    }

    /// Unsubscribe Label for realtime updates.
    @objc func unsubscribeForRealtimeUpdates() {
        RealtimeUpdateFeature.shared?.unsubscribe(control: self)
    }
}
#endif
