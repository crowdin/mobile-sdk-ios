//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Foundation

/// Closure type for localization update download handlers.
public typealias CrowdinSDKLocalizationUpdateDownload = () -> Void

/// Closure type for localization update error handlers.
public typealias CrowdinSDKLocalizationUpdateError = ([Error]) -> Void

/// Closure type for Log messages handlers.
public typealias CrowdinSDKLogMessage = (String) -> Void

/// Main interface for working with CrowdinSDK library.
@objcMembers public class CrowdinSDK: NSObject {

    public var onLogCallback: ((String) -> Void)?

    /// Current localization language code. If SDK is started than after setting new localization it triggers localization download.
	public class var currentLocalization: String? {
		get {
            return Localization.currentLocalization ?? Localization.current?.provider.localization
		}
		set {
			Localization.currentLocalization = newValue
		}
	}

    /// List of available localizations in SDK.
	public class var inSDKLocalizations: [String] { return Localization.current?.inProvider ?? [] }

    /// List of supported in app localizations.
    public class var inBundleLocalizations: [String] { Bundle.main.inBundleLocalizations }

    /// List of all available localizations in bundle and on crowdin.
    public class var allAvailableLocalizations: [String] {
        var localizations = Array(Set<String>(inSDKLocalizations + inBundleLocalizations))
        if let index = localizations.firstIndex(where: { $0 == "Base" }) {
            localizations.remove(at: index)
        }
        return localizations
    }

    // swiftlint:disable implicitly_unwrapped_optional
    static var config: CrowdinSDKConfig!

    ///
    public class func stop() {
        CrowdinSDK.stopRealtimeUpdatesFeatureIfNeeded()
        self.unswizzle()
        Localization.current = nil
    }

    /// Initialization method. Initialize library with passed localization provider.
    ///
    /// - Parameter remoteStorage: Custom localization remote storage which will be used to download localizations.
    /// - Parameter completion: Remote storage preparation completion handler. Called when all required data is downloaded.
    class func startWithRemoteStorage(_ remoteStorage: RemoteLocalizationStorageProtocol, completion: @escaping () -> Void) {
        let localizations = remoteStorage.localizations + self.inBundleLocalizations
        let localization = self.currentLocalization ?? Bundle.main.preferredLanguage(with: localizations)
        let localStorage = LocalLocalizationStorage(localization: localization)
        let localizationProvider = LocalizationProvider(localization: localization, localStorage: localStorage, remoteStorage: remoteStorage)

        Localization.current = Localization(provider: localizationProvider)

        initializeLib()

        localizationProvider.prepare(with: completion)
    }

    /// Removes all stored information by SDK from application Documents folder. Use to clean up all files used by SDK.
    public class func deintegrate() {
        Localization.current?.provider.deintegrate()
    }

    /// Method for changing SDK localization
    ///
    /// - Parameters:
    ///   - sdkLocalization: Bool value which indicate whether to use SDK localization or native in bundle localization.
    ///   - localization: Localization code to use.
    @available(*, deprecated, message: "Please use currentLocalization instead.")
    public class func enableSDKLocalization(_ sdkLocalization: Bool, localization: String?) {
        self.currentLocalization = localization
    }

    /// Utils method for extracting all localization strings and plurals to Documents folder. This method will extract all localization for all languages and store it in Extracted subfolder in Crowdin folder.
    public class func extractAllLocalization() {
        guard let folder = try? CrowdinFolder.shared.createFolder(with: "Extracted") else { return }
        LocalLocalizationExtractor.extractAllLocalizationStrings(to: folder.path)
        LocalLocalizationExtractor.extractAllLocalizationPlurals(to: folder.path)
    }

    /// Add download handler closure. This closure will be called every time when new localization is downloaded.
    ///
    /// - Parameter handler: Download handler closure.
    /// - Returns: Download handler id value. This value is used to remove this handler.
    public class func addDownloadHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateDownload) -> Int {
        return LocalizationUpdateObserver.shared.addDownloadHandler(handler)
    }

    /// Method for removing localization download completion handler by id.
    ///
    /// - Parameter id: Handler id returned from addDownloadHandler(_:) method.
    public class func removeDownloadHandler(_ id: Int) {
        LocalizationUpdateObserver.shared.removeDownloadHandler(id)
    }

    /// Remove all download completion handlers.
    public class func removeAllDownloadHandlers() {
        LocalizationUpdateObserver.shared.removeAllDownloadHandlers()
    }

    /// Method for adding localization download error handler.
    ///
    /// - Parameter handler: Download error closure.
    /// - Returns: Handler id needed to unsubscribe.
    public class func addErrorUpdateHandler(_ handler: @escaping CrowdinSDKLocalizationUpdateError) -> Int {
        return LocalizationUpdateObserver.shared.addErrorHandler(handler)
    }

    /// Method for removing localization download error handler.
    ///
    /// - Parameter id: Handler id returned from addErrorUpdateHandler(_:) method.
    public class func removeErrorHandler(_ id: Int) {
        LocalizationUpdateObserver.shared.removeErrorHandler(id)
    }

    /// Method for removing all localization download error handlers.
    public class func removeAllErrorHandlers() {
        LocalizationUpdateObserver.shared.removeAllErrorHandlers()
    }

    /// Add log message handler closure. This closure will be called every time when new log record is created.
    ///
    /// - Parameter handler: Log message handler closure.
    /// - Returns: Log handler id value. This value is used to remove this handler.
    @discardableResult
    public class func addLogMessageHandler(_ handler: @escaping CrowdinSDKLogMessage) -> Int {
        LogMessageObserver.shared.addLogMessageHandler(handler)
    }

    /// Method for removing log message completion handler by id.
    ///
    /// - Parameter id: Handler id returned from addLogMessageHandler(_:) method.
    public class func removeLogMessageHandler(_ id: Int) {
        LogMessageObserver.shared.removeLogMessageHandler(id)
    }

    /// Remove all completion handlers.
    public class func removeAllLogMessageHandlers() {
        LogMessageObserver.shared.removeAllLogMessageHandlers()
    }

    /// Get lokalization key for a string. First it will search in crowdin localization provider, than in local strings.
    /// - Parameter string: String to get localization key for,
    /// - Returns: Localization key for a given string.
    public class func keyFor(string: String) -> String? {
        Localization.current?.keyForString(string)
    }
}

extension CrowdinSDK {
    /// Method for swizzling Bundle methods.
    class func swizzle() {
        if !Bundle.isSwizzled {
            Bundle.swizzle()
        }
    }

    /// Method for unswizzling all swizzled methods.
    class func unswizzle() {
        if Bundle.isSwizzled {
            Bundle.unswizzle()
        }

        if CWLabel.isSwizzled {
            CWLabel.unswizzle()
        }
#if os(iOS) || os(tvOS)
        if UIButton.isSwizzled {
            UIButton.unswizzle()
        }
#elseif os(macOS)
        if NSButton.isSwizzled {
            NSButton.unswizzle()
        }
#endif
    }

    /// Swizzle methods for Label and Button. Needed for screenshots and real-time preview.
    class func swizzleControlMethods() {
        if !CWLabel.isSwizzled {
            CWLabel.swizzle()
        }
#if os(iOS) || os(tvOS)
        if !UIButton.isSwizzled {
            UIButton.swizzle()
        }
#elseif os(macOS)
        if !NSButton.isSwizzled {
            NSButton.swizzle()
        }
#endif
    }

    /// Unswizzle methods for Label and Button.
    class func unswizzleControlMethods() {
        if CWLabel.isSwizzled {
            CWLabel.unswizzle()
        }
#if os(iOS) || os(tvOS)
        if UIButton.isSwizzled {
            UIButton.unswizzle()
        }
#elseif os(macOS)
        if NSButton.isSwizzled {
            NSButton.unswizzle()
        }
#endif
    }
}

extension CrowdinSDK {
    /// Selectors for all feature initialization.
    ///
    /// - initializeScreenshotFeature: Selector for Screenshots feature initialization.
	/// - initializeRealtimeUpdatesFeature: Selector for RealtimeUpdates feature initialization.
	/// - initializeIntervalUpdateFeature: Selector for IntervalUpdate feature initialization.
	/// - initializeSettings: Selector for Settings feature initialization.
    enum Selectors: Selector {
        case initializeScreenshotFeature
        case initializeRealtimeUpdatesFeature
        case stopRealtimeUpdates
        case initializeIntervalUpdateFeature
        case initializeSettings
		case setupLogin
    }

    /// Method for library initialization.
    class func initializeLib() {
        self.swizzle()

        self.setupLoginIfNeeded()

        self.initializeScreenshotFeatureIfNeeded()

        self.initializeRealtimeUpdatesFeatureIfNeeded()

        self.initializeIntervalUpdateFeatureIfNeeded()

        self.initializeSettingsIfNeeded()
    }

    /// Method for screenshot feature initialization if Screenshot submodule is added.
    private class func initializeScreenshotFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeScreenshotFeature.rawValue) {
            CrowdinSDK.perform(Selectors.initializeScreenshotFeature.rawValue)
        }
    }

    /// Method for real-time updates feature initialization if RealtimeUpdate submodule is added.
    private class func initializeRealtimeUpdatesFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeRealtimeUpdatesFeature.rawValue) {
            CrowdinSDK.perform(Selectors.initializeRealtimeUpdatesFeature.rawValue)
        }
    }

    /// Method for stopping real-time updates feature if RealtimeUpdate submodule is added and enabled.
    private class func stopRealtimeUpdatesFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.stopRealtimeUpdates.rawValue) {
            CrowdinSDK.perform(Selectors.stopRealtimeUpdates.rawValue)
        }
    }

	/// Method for interval updates feature initialization if IntervalUpdate submodule is added.
    private class func initializeIntervalUpdateFeatureIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeIntervalUpdateFeature.rawValue) {
            CrowdinSDK.perform(Selectors.initializeIntervalUpdateFeature.rawValue)
        }
    }

	/// Method for Settings view feature initialization if Screenshots submodule is added.
    private class func initializeSettingsIfNeeded() {
        if CrowdinSDK.responds(to: Selectors.initializeSettings.rawValue) {
            CrowdinSDK.perform(Selectors.initializeSettings.rawValue)
        }
    }

	private class func setupLoginIfNeeded() {
		if CrowdinSDK.responds(to: Selectors.setupLogin.rawValue) {
			CrowdinSDK.perform(Selectors.setupLogin.rawValue)
		}
	}
}
