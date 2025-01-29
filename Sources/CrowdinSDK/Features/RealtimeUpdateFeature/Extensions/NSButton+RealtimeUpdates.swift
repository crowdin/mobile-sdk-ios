//
//  NSButton+RealtimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/5/19.
//

#if os(macOS)
import AppKit

extension NSButton {
    /// Subscribe NSButton for realtime updates if it has at least one localization key for any state and realtime updates feature enabled.
    @objc func subscribeForRealtimeUpdates() {
        if self.localizationKey != nil {
            RealtimeUpdateFeature.shared?.subscribe(control: self)
        }
    }

    /// Unsubscribe NSButton from realtime updates.
    @objc func unsubscribeForRealtimeUpdates() {
        RealtimeUpdateFeature.shared?.unsubscribe(control: self)
    }
}
#endif
