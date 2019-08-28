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
        if config.reatimeUpdatesEnabled {
            let localization = Bundle.main.preferredLanguage(with: crowdinProviderConfig.localizations)
			// TODO: Add error message when login is not configured:
			guard let crowdinLoginConfig = config.loginConfig as? CrowdinLoginConfig else { return }
            RealtimeUpdateFeature.shared = RealtimeUpdateFeature(localization: localization, strings: crowdinProviderConfig.stringsFileNames, plurals: crowdinProviderConfig.pluralsFileNames, hash: crowdinProviderConfig.hashString, sourceLanguage: crowdinProviderConfig.sourceLanguage, organizationName: crowdinLoginConfig.organizationName)
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
