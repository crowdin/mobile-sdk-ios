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

        if let loginFeature = CrowdinSDK.loginFeature {
            let logInItemView = SettingsItemView(frame: .zero)
            if !loginFeature.isLogined {
                logInItemView.title = "Log in"
                logInItemView.action = { [weak self] in
                    loginFeature.login(completion: {
                        DispatchQueue.main.async {
                            self?.reload()
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
                logInItemView.action = {
                    self.showLogoutClearCredentialsAlert(completion: { [weak self] in
                        self?.reload()
                    })
                }
            }
            logInItemView.statusView.backgroundColor = loginFeature.isLogined ? self.enabledStatusColor : .clear
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

        if CrowdinSDK.loginFeature?.isLogined == true {
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
                    self.presentEnterScreenshotNameAlert { screenshotName in
                        feature.updateOrUploadScreenshot(name: screenshotName, success: { result in
                            let message = result == .new ? "New Screenshot Uploaded" : "Screenshot Updated"
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: message))
                        }, errorHandler: { (error) in
                            let message = "Error while capturing screenshot - \(error?.localizedDescription ?? "Unknown")"
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: message))
                        })
                    }
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
                if #available(iOS 13.0, tvOS 13.0, *) {
                    settingsView.settingsWindow.windowScene = nil
                }
                SettingsView.shared = nil
            }
        }
        stopItem.title = "Stop"
        stopItem.statusView.isHidden = true
        cells.append(stopItem)
    }

    func reload() {
        reloadData()
        reloadUI()
    }

    func presentEnterScreenshotNameAlert(title: String = "Enter screenshot name",
                                         message: String = "Please provide screenshot name value",
                                         onSubmit: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Create submit action with disabled state initially
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alert] _ in
            guard let text = alert?.textFields?.first?.text,
                  text.validateScreenshotName() else { return }
            onSubmit(text.trimmingCharacters(in: .whitespacesAndNewlines))
            alert?.cw_dismiss()
        }
        submitAction.isEnabled = false

        alert.addTextField { textField in
            textField.placeholder = "Screenshot name (avoid \\/:*?\"<>|)"
            // Add target to monitor text changes
            textField.addTarget(alert, action: #selector(UIAlertController.textDidChange), for: .editingChanged)
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Use timestamp", style: .default) { _ in
            onSubmit(String(Int(Date().timeIntervalSince1970)))
            alert.cw_dismiss()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.cw_dismiss()
        })

        // Store submit action reference using ObjectAssociation
        alert.submitAction = submitAction

        alert.cw_present()
    }

    func showLogoutClearCredentialsAlert(completion: @escaping () -> Void) {
        let title = "CrowdinSDK"
        let message = "Do you want to clear your previous login session? All your credentials will be deleted."
        let yesTitle = "YES"
        let noTitle = "NO"
        let cancelTitle = "Cancel"
#if os(iOS)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: yesTitle, style: .default, handler: { _ in
            alert.cw_dismiss()
            CrowdinSDK.loginFeature?.logout(clearCreditials: true, completion: completion)
            completion()
        }))
        alert.addAction(UIAlertAction(title: noTitle, style: .default, handler: { _ in
            alert.cw_dismiss()
            CrowdinSDK.loginFeature?.logout(clearCreditials: false, completion: completion)
            completion()
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .destructive, handler: { _ in
            alert.cw_dismiss()
            completion()
        }))
        alert.cw_present()
#elseif os(macOS)
        guard let window = NSApplication.shared.windows.first else { return }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        let action = alert.addButton(withTitle: yesTitle)
        alert.addButton(withTitle: cancelTitle)
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window) { response in
            if response.rawValue == 1000 {

            }
        }
#endif
    }

}

// MARK: - Alert Text Field Validation
private extension UIAlertController {
    private static let submitActionAssociation = ObjectAssociation<UIAlertAction>()

    var submitAction: UIAlertAction? {
        get { return Self.submitActionAssociation[self] }
        set { Self.submitActionAssociation[self] = newValue }
    }

    @objc func textDidChange() {
        if let textField = textFields?.first,
           let text = textField.text {
            submitAction?.isEnabled = text.validateScreenshotName()
        }
    }
}

#endif
