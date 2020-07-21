//
//  CrowdinSDK+ReatimeUpdates.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/1/19.
//

import Foundation

extension CrowdinSDK {
    class func initializeRealtimeUpdatesFeature() {
        guard let config = CrowdinSDK.config else { return }
        let crowdinProviderConfig = config.crowdinProviderConfig ?? CrowdinProviderConfig()
        if config.realtimeUpdatesEnabled {
            let hash = crowdinProviderConfig.hashString
            let localizations = ManifestManager.shared(for: hash).iOSLanguages
            let localization = Bundle.main.preferredLanguage(with: localizations)
            RealtimeUpdateFeature.shared = RealtimeUpdateFeature(localization: localization, hash: crowdinProviderConfig.hashString, sourceLanguage: crowdinProviderConfig.sourceLanguage, organizationName: config.loginConfig?.organizationName)
        }
    }
    
    public class func startRealtimeUpdates(success: (() -> Void)?, error: ((Error) -> Void)?) {
        guard let realtimeUpdateFeature = RealtimeUpdateFeature.shared else { return }
        realtimeUpdateFeature.start(success: success, error: error)
    }
    
    public class func stopRealtimeUpdates() {
        guard let realtimeUpdateFeature = RealtimeUpdateFeature.shared else { return }
        realtimeUpdateFeature.stop()
    }
    
    /// Reload localization for all UI controls(UILabel, UIButton). Works only if realtime update feature is enabled.
    public class func reloadUI() {
        DispatchQueue.main.async { RealtimeUpdateFeature.shared?.refreshAllControls() }
    }
}
