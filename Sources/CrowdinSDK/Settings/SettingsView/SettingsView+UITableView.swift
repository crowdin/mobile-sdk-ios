//
//  SettingsView+UITableView.swift
//  BaseAPI
//
//  Created by Serhii Londar on 4/6/19.
//

#if os(iOS) || os(tvOS)

import UIKit

extension SettingsView {
    func setupCells() {
        cells = []

        if let loginFeature = LoginFeature.shared {
            let logInItemView = SettingsItemView(frame: .zero)
            if !LoginFeature.isLogined {
                logInItemView.title = "Log in"
                logInItemView.action = { [weak self] in
                    loginFeature.login(completion: {
                        DispatchQueue.main.async {
                            self?.reloadData()
                            self?.reloadUI()
                        }
                        let message = "Logged in"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                    }, error: { error in
                        let message = "Login error - \(error.localizedDescription)"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                    })
                    self?.isHidden = false
                    self?.reloadData()
                }
            } else {
                logInItemView.title = "Logged in"
                logInItemView.action = { [weak self] in
                    self?.showConfirmationLogoutAlert()
                }
            }
            logInItemView.statusView.backgroundColor = LoginFeature.isLogined ? self.enabledStatusColor : .clear
            logInItemView.statusView.isHidden = false
            cells.append(logInItemView)
        }

        let reloadItemView = SettingsItemView(frame: .zero)
        reloadItemView.action = {
            RefreshLocalizationFeature.refreshLocalization()

            let message = RealtimeUpdateFeature.shared?.enabled == true ? "Localization fetched from Crowdin project" : "Localization fetched from distribution"
            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
        }

        reloadItemView.title = "Reload translations"
        cells.append(reloadItemView)

        if LoginFeature.isLogined {
            if var feature = RealtimeUpdateFeature.shared {
                let realTimeUpdateItemView = SettingsItemView(frame: .zero)
                feature.error = { error in
                    let message = "Error while starting real-time preview - \(error.localizedDescription)"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                }

                feature.success = { [weak self] in
                    let message = "Successfully started real-time preview"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))

                    self?.reloadData()
                    guard RealtimeUpdateFeature.shared?.enabled == false else {
                        return
                    }
                }
                feature.disconnect = { [weak self] in
                    let message = "Real-time preview disabled"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))

                    self?.reloadData()
                }

                realTimeUpdateItemView.action = {
                    feature.enabled = !feature.enabled
                    realTimeUpdateItemView.title = feature.enabled ? "Real-time on" : "Real-time off"
                }
                realTimeUpdateItemView.title = feature.enabled ? "Real-time on" : "Real-time off"
                realTimeUpdateItemView.statusView.backgroundColor = feature.enabled ? self.enabledStatusColor : .clear
                realTimeUpdateItemView.statusView.isHidden = false
                cells.append(realTimeUpdateItemView)
            }

            if let feature = ScreenshotFeature.shared {
                let screenshotItemView = SettingsItemView(frame: .zero)
                screenshotItemView.action = {
                    let message = "Screenshot captured"
                    feature.captureScreenshot(name: String(Date().timeIntervalSince1970), success: {
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                    }, errorHandler: { (error) in
                        let message = "Error while capturing screenshot - \(error?.localizedDescription ?? "Unknown")"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                    })
                }

                screenshotItemView.title = "Capture screenshot"
                screenshotItemView.statusView.isHidden = true
                cells.append(screenshotItemView)
            }
        }

        let logsItemView = SettingsItemView(frame: .zero)
        logsItemView.action = {
            let logsVC = CrowdinLogsVC()
            let logsNC = UINavigationController(rootViewController: logsVC)
            logsVC.title = "Logs"
            logsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: logsNC, action: #selector(UIViewController.cw_dismiss))
            logsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear logs", style: .done, target: logsNC, action: #selector(UIViewController.cw_askToClearLogsAlert))
            logsNC.modalPresentationStyle = .fullScreen
            logsNC.cw_present()
        }
        logsItemView.title = "Logs"
        logsItemView.statusView.isHidden = true
        cells.append(logsItemView)

        let stopItem = SettingsItemView(frame: .zero)
        stopItem.action = {
            CrowdinSDK.stop()
            if let settingsView = SettingsView.shared {
                settingsView.removeFromSuperview()
                settingsView.settingsWindow.isHidden = true
                if #available(iOS 13.0, tvOS 13.0,  *) {
                    settingsView.settingsWindow.windowScene = nil
                }
                SettingsView.shared = nil
            }
        }
        stopItem.title = "Stop"
        stopItem.statusView.isHidden = true
        cells.append(stopItem)
    }
}

#endif
