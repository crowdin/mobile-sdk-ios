//
//  SettingsWindow.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 04.12.2020.
//

#if os(iOS) || os(tvOS)

import UIKit
import CoreGraphics

class SettingsWindow: UIWindow {
    weak var settingsView: SettingsView? {
        didSet {
            if let view = oldValue {
                view.removeFromSuperview()
            }
            if let view = settingsView {
                self.addSubview(view)
            }
        }
    }

    init() {
        if #available(iOS 13.0, tvOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
                super.init(windowScene: windowScene)
            } else {
                super.init(frame: UIScreen.main.bounds)
            }
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        backgroundColor = .clear
        windowLevel = UIWindow.Level.statusBar + 1

        if #available(iOS 13.0, tvOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivate(_:)), name: UIScene.didActivateNotification, object: nil)
        }
    }

    @available(iOS 13.0, tvOS 13.0, *)
    @objc private func sceneDidActivate(_ notification: Notification) {
        if self.windowScene == nil, let scene = notification.object as? UIWindowScene {
            self.windowScene = scene
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let settingsView = settingsView else { return false }
        let buttonPoint = convert(point, to: settingsView)
        return settingsView.point(inside: buttonPoint, with: event)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

#endif
