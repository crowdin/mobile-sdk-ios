//
//  SettingsView+UITableView.swift
//  BaseAPI
//
//  Created by Serhii Londar on 4/6/19.
//

import UIKit

extension SettingsView {
    func setupCells() {
        cells = []
        
        if let loginFeature = LoginFeature.shared {
            let settingsItemView = SettingsItemView(frame: .zero)
            if !LoginFeature.isLogined {
                settingsItemView.title = "Log in"
                settingsItemView.action = { [weak self] in
                    loginFeature.login(completion: {
                        DispatchQueue.main.async {
                            self?.reloadData()
                            self?.reloadUI()
                        }
                        let message = "Successfully logined"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                        self?.showToast(message)
                    }, error: { [weak self] error in
                        let message = "Login error - \(error.localizedDescription)"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                        self?.showToast(message)
                    })
                    self?.isHidden = false
                    self?.reloadData()
                }
            } else {
                settingsItemView.title = "Logged in"
                settingsItemView.action = { [weak self] in
                    self?.showConfirmationLogoutAlert()
                }
            }
            settingsItemView.statusView.backgroundColor = LoginFeature.isLogined ? self.enabledStatusColor : .clear
            settingsItemView.statusView.isHidden = false
            cells.append(settingsItemView)
            
        }
        
        var settingsItemView = SettingsItemView(frame: .zero)
        settingsItemView.action = { [weak self] in
            RefreshLocalizationFeature.refreshLocalization()
            let message = RealtimeUpdateFeature.shared?.enabled == true ? "Localization fetched from Crowdin project" : "Localization fetched from distribution"
            self?.showToast(message)
        }
        settingsItemView.title = "Reload translations"
        cells.append(settingsItemView)
        
        if LoginFeature.isLogined {
            if var feature = RealtimeUpdateFeature.shared {
                settingsItemView = SettingsItemView(frame: .zero)
                feature.error = { [weak self] error in
                    let message = "Error while starting real-time preview - \(error.localizedDescription)"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                    self?.showToast(message)
                }
                
                feature.success = { [weak self] in
                    let message = "Successfully started real-time preview"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                    self?.reloadData()
                    guard RealtimeUpdateFeature.shared?.enabled == false else {
                        return
                    }
                    self?.showToast(message)
                }
                feature.disconnect = { [weak self] in
                    let message = "Real-time preview disabled"
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                    self?.reloadData()
                    self?.showToast(message)
                }
                
                settingsItemView.action = {
                    feature.enabled = !feature.enabled
                    settingsItemView.title = feature.enabled ? "Real-time on" : "Real-time off"
                }
                settingsItemView.title = feature.enabled ? "Real-time on" : "Real-time off"
                settingsItemView.statusView.backgroundColor = feature.enabled ? self.enabledStatusColor : .clear
                settingsItemView.statusView.isHidden = false
                cells.append(settingsItemView)
            }
            
            if let feature = ScreenshotFeature.shared {
                let settingsItemView = SettingsItemView(frame: .zero)
                settingsItemView.action = { [weak self] in
                    let message = "Successfully captured screenshot"
                    feature.captureScreenshot(name: String(Date().timeIntervalSince1970), success: {
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                        self?.showToast(message)
                    }, errorHandler: { (error) in
                        let message = "Error while capturing screenshot - \(error?.localizedDescription ?? "Unknown")"
                        CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                        self?.showToast(message)
                    })
                }
                settingsItemView.title = "Capture screenshot"
                settingsItemView.statusView.isHidden = true
                cells.append(settingsItemView)
            }
        }
        
        settingsItemView = SettingsItemView(frame: .zero)
        settingsItemView.action = {
            let logsVC = CrowdinLogsVC()
            let logsNC = UINavigationController(rootViewController: logsVC)
            logsVC.title = "Logs"
            logsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: logsNC, action: #selector(UIViewController.cw_dismiss))
            logsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear logs", style: .done, target: logsNC, action: #selector(UIViewController.cw_askToClearLogsAlert))
            logsNC.modalPresentationStyle = .fullScreen
            logsNC.cw_present()
        }
        settingsItemView.title = "Logs"
        settingsItemView.statusView.isHidden = true
        cells.append(settingsItemView)
        
        settingsItemView = SettingsItemView(frame: .zero)
        settingsItemView.action = {
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
        settingsItemView.title = "Stop"
        settingsItemView.statusView.isHidden = true
        cells.append(settingsItemView)
    }
}
