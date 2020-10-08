//
//  SettingsView+UITableView.swift
//  BaseAPI
//
//  Created by Serhii Londar on 4/6/19.
//

import Foundation

extension SettingsView {
    func registerCells() {
        let nib = UINib(nibName: "SettingsItemCell", bundle: Bundle.resourceBundle)
        tableView.register(nib, forCellReuseIdentifier: "SettingsItemCell")
    }
    
    func setupCells() {
        cells = []
        
        if let loginFeature = LoginFeature.shared {
            if let loginCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                if !LoginFeature.isLogined {
                    loginCell.titleLabel.text = "Log in"
                    loginCell.action = {
                        loginFeature.login(completion: {
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Successfully logined"))
                        }, error: { (error) in
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Login error - \(error.localizedDescription)"))
                        })
                        self.isHidden = false
                        self.open = false
                    }
                } else {
                    loginCell.titleLabel.text = "Logged in"
                    loginCell.action = {
                        if let realtimeUpdateFeature = RealtimeUpdateFeature.shared, realtimeUpdateFeature.enabled {
                            realtimeUpdateFeature.stop()
                        }
                        loginFeature.logout()
                        self.open = false
                    }
                }
                loginCell.statusView.backgroundColor = LoginFeature.isLogined ? self.enabledStatusColor : .clear
                cells.append(loginCell)
            }
        }
        
        if let reloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            reloadCell.action = {
                RefreshLocalizationFeature.refreshLocalization()
                self.open = false
            }
            reloadCell.titleLabel.text = "Force reload"
            reloadCell.selectionStyle = .none
            cells.append(reloadCell)
        }
        /*
        if var feature = IntervalUpdateFeature.shared {
            if let autoreloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                autoreloadCell.action = {
                    feature.enabled = !feature.enabled
                    autoreloadCell.icon.image = UIImage(named: feature.enabled ? "auto-updates-on" : "auto-updates-off", in: Bundle.resourceBundle, compatibleWith: nil)
                    self.tableView.reloadData()
                    self.open = false
                }
                autoreloadCell.icon.image = UIImage(named: feature.enabled ? "auto-updates-on" : "auto-updates-off", in: Bundle.resourceBundle, compatibleWith: nil)
                autoreloadCell.selectionStyle = .none
                autoreloadCell.contentView.layer.cornerRadius = 30.0
                autoreloadCell.contentView.clipsToBounds = true
                cells.append(autoreloadCell)
            }
        }
        */
        if LoginFeature.isLogined {
            if var feature = RealtimeUpdateFeature.shared {
                if let realtimeUpdateCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                    if feature.error == nil {
                        feature.error = { error in
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Error while starting real-time preview - \(error.localizedDescription)"))
                        }
                    }
                    if feature.success == nil {
                        feature.success = {
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Successfully started real-time preview"))
                        }
                    }
                    realtimeUpdateCell.action = {
                        feature.enabled = !feature.enabled
                        realtimeUpdateCell.titleLabel.text = feature.enabled ? "Real-time on" : "Real-time off"
                        self.tableView.reloadData()
                        self.open = false
                    }
                    realtimeUpdateCell.titleLabel.text = feature.enabled ? "Real-time on" : "Real-time off"
                    realtimeUpdateCell.statusView.backgroundColor = feature.enabled ? self.enabledStatusColor : .clear
                    realtimeUpdateCell.selectionStyle = .none
                    cells.append(realtimeUpdateCell)
                    
                }
            }
            
            if let feature = ScreenshotFeature.shared {
                if let screenshotCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                    screenshotCell.action = {
                        self.isHidden = true
                        feature.captureScreenshot(name: String(Date().timeIntervalSince1970), success: {
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Successfully captured screenshot"))
                        }, errorHandler: { (error) in
                            CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .error, message: "Error while capturing screenshot - \(error?.localizedDescription ?? "Unknown")"))
                        })
                        self.isHidden = false
                        self.open = false
                    }
                    screenshotCell.titleLabel.text = "Capture screenshot"
                    cells.append(screenshotCell)
                }
            }
        }
        
        if let logsCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            logsCell.action = {
                let logsVCStoryboard = UIStoryboard(name: "CrowdinLogsVC", bundle: Bundle.resourceBundle)
                let logsVC = logsVCStoryboard.instantiateViewController(withIdentifier: "CrowdinLogsVC")
                let logsNC = UINavigationController(rootViewController: logsVC)
                logsVC.title = "Logs"
                logsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: logsNC, action: #selector(UIViewController.cw_dismiss))
                logsNC.modalPresentationStyle = .fullScreen
                logsNC.cw_present()
                self.isHidden = false
                self.open = false
            }
            logsCell.titleLabel.text = "Logs"
            cells.append(logsCell)
        }
    }
}

extension SettingsView: UITableViewDelegate {
    
}

extension SettingsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cells[indexPath.row].action?()
    }
}
