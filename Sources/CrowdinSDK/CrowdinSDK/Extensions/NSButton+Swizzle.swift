//
//  NSButton+Swizzle.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/27/19.
//

#if os(macOS)
import AppKit

// MARK: - NSButton extension with core functionality for language substitution.
extension NSButton {
    /// Association object for storing localization keys for different states.
    private static let localizationKeyAssociation = ObjectAssociation<String>()

    /// Dictionary with localization keys for different states.
    var localizationKey: String? {
        get { return NSButton.localizationKeyAssociation[self] }
        set { NSButton.localizationKeyAssociation[self] = newValue }
    }

    /// Association object for storing localization format string values if such exists.
    private static let localizationValuesAssociation = ObjectAssociation<[Any]>()

    /// Dictionary with localization format string values for different state.
    var localizationValues: [Any]? {
        get { return NSButton.localizationValuesAssociation[self] }
        set { NSButton.localizationValuesAssociation[self] = newValue }
    }

    /// Association object for storing localization format string values if such exists.
    private static let usingAttributedTitleAssociation = ObjectAssociation<Bool>()

    /// Store boolean value which indicates whether title was set as attributed string.
    var usingAttributedTitle: Bool {
        get { return NSButton.usingAttributedTitleAssociation[self] ?? false }
        set { NSButton.usingAttributedTitleAssociation[self] = newValue }
    }

    // swiftlint:disable implicitly_unwrapped_optional
    /// Original setTitle(_:for:) method.
    static var originalSetTitle: Method!
    /// Swizzled setTitle(_:for:) method.
    static var swizzledSetTitle: Method!
    /// Original setAttributedTitle(_:for:) method.
    static var originalSetAttributedTitle: Method!
    /// Swizzled setAttributedTitle(_:for:) method.
    static var swizzledSetAttributedTitle: Method!

    static var isSwizzled: Bool {
        return originalSetTitle != nil && swizzledSetTitle != nil && originalSetAttributedTitle != nil && swizzledSetAttributedTitle != nil
    }

    /// Swizzled implementation for setTitle(_:for:) method.
    ///
    /// - Parameters:
    ///   - title: Title string.
    ///   - state: The state that uses the specified title.
    @objc func swizzled_setTitle(_ title: String?) {
        proceed(title: title)
        swizzled_setTitle(title)
        usingAttributedTitle = false
    }

    /// Swizzled implementation for setAttributedTitle(_:for:) method.
    ///
    /// - Parameters:
    ///   - title: Title attributed string.
    ///   - state: The state that uses the specified title.
    @objc func swizzled_setAttributedTitle(_ title: NSAttributedString?) {
        // TODO: Add saving attributes.
        let titleString = title?.string
        proceed(title: titleString)
        swizzled_setAttributedTitle(title)
        usingAttributedTitle = true
    }

    /// Method for title string processing. Detect localization key for this string and store all needed values for this string.
    ///
    /// - Parameters:
    ///   - title: Title string to proceed.
    ///   - state: The state that uses the specified title.
    func proceed(title: String?) {
        if let title = title {
            if let key = Localization.current.keyForString(title) {
                // Try to find values for key (formated strings, plurals)
                if let string = Localization.current.localizedString(for: key), string.isFormated {
                    if let values = Localization.current.findValues(for: title, with: string) {
                        self.localizationValues = values
                    }
                }
                self.localizationKey = key
            }
            self.subscribeForRealtimeUpdatesIfNeeded()
        } else {
            self.localizationKey = nil
            self.localizationValues = nil
            self.unsubscribeFromRealtimeUpdatesIfNeeded()
        }
    }

    func cw_setTitle(_ title: String?) {
        if usingAttributedTitle {
            // TODO: Apply attributes.
            original_setAttributedTitle(NSAttributedString(string: title ?? ""))
        } else {
            original_setTitle(title)
        }
    }

    /// Original method for setting title string for button after swizzling.
    ///
    /// - Parameters:
    ///   - title: Title string.
    ///   - state: The state that uses the specified title.
    private func original_setTitle(_ title: String?) {
        guard NSButton.swizzledSetTitle != nil else { return }
        swizzled_setTitle(title)
    }

    /// Original method for setting attributed title string for button after swizzling.
    ///
    /// - Parameters:
    ///   - title: Title attributed string.
    ///   - state: The state that uses the specified title.
    private func original_setAttributedTitle(_ title: NSAttributedString?) {
        // TODO: Add saving attributes.
        guard NSButton.swizzledSetAttributedTitle != nil else { return }
        swizzled_setAttributedTitle(title)
    }

    /// Method for swizzling implementations for setTitle(_:for:) and setAttributedTitle(_:for:) methods.
    /// Note: This method should be called only when we need to get localization key from string, currently it is needed for screenshots and realtime preview features.
    class func swizzle() {
        // swiftlint:disable force_unwrapping
        originalSetTitle = class_getInstanceMethod(self, #selector(setter: NSButton.title))!
        swizzledSetTitle = class_getInstanceMethod(self, #selector(NSButton.swizzled_setTitle(_:)))!
        method_exchangeImplementations(originalSetTitle, swizzledSetTitle)

        originalSetAttributedTitle = class_getInstanceMethod(self, #selector(setter: NSButton.attributedTitle))!
        swizzledSetAttributedTitle = class_getInstanceMethod(self, #selector(NSButton.swizzled_setAttributedTitle(_:)))!
        method_exchangeImplementations(originalSetAttributedTitle, swizzledSetAttributedTitle)
    }

    /// Method for swizzling implementations back for setTitle(_:for:) and setAttributedTitle(_:for:) methods.
    class func unswizzle() {
        if originalSetTitle != nil && swizzledSetTitle != nil {
            method_exchangeImplementations(swizzledSetTitle, originalSetTitle)
            swizzledSetTitle = nil
            originalSetTitle = nil
        }
        if originalSetAttributedTitle != nil && swizzledSetAttributedTitle != nil {
            method_exchangeImplementations(swizzledSetAttributedTitle, originalSetAttributedTitle)
            swizzledSetAttributedTitle = nil
            originalSetAttributedTitle = nil
        }
    }

    /// Selectors for working with real-time updates.
    ///
    /// - subscribeForRealtimeUpdates: Method for subscribing to real-time updates.
    /// - unsubscribeForRealtimeUpdates: Method for unsubscribing from real-time updates.
    enum Selectors: Selector {
        case subscribeForRealtimeUpdates
        case unsubscribeFromRealtimeUpdates
    }

    /// Method for subscription to real-time updates if real-time feature enabled.
    func subscribeForRealtimeUpdatesIfNeeded() {
        if self.responds(to: Selectors.subscribeForRealtimeUpdates.rawValue) {
            self.perform(Selectors.subscribeForRealtimeUpdates.rawValue)
        }
    }

    /// Method for unsubscribing from real-time updates if real-time feature enabled.
    func unsubscribeFromRealtimeUpdatesIfNeeded() {
        if self.responds(to: Selectors.unsubscribeFromRealtimeUpdates.rawValue) {
            self.perform(Selectors.unsubscribeFromRealtimeUpdates.rawValue)
        }
    }
}

#endif
