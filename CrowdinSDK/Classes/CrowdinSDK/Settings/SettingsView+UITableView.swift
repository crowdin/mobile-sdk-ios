//
//  SettingsView+UITableView.swift
//  BaseAPI
//
//  Created by Serhii Londar on 4/6/19.
//

import Foundation

extension SettingsView {
    func registerCells() {
        let bundle = Bundle(for: SettingsView.self)
        let nib = UINib(nibName: "SettingsItemCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "SettingsItemCell")
    }
    
    func setupCells() {
        cells = []
        let bundle = Bundle(for: SettingsView.self)
        
        if let reloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            reloadCell.action = {
                ForceRefreshLocalizationFeature.refreshLocalization()
                self.open = false
            }
            reloadCell.icon.image = UIImage(named: "reload", in: bundle, compatibleWith: nil)
            reloadCell.selectionStyle = .none
            reloadCell.contentView.layer.cornerRadius = 30.0
            reloadCell.contentView.clipsToBounds = true
            cells.append(reloadCell)
        }
        
        if let feature = IntervalUpdateFeature.shared {
            if let autoreloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                autoreloadCell.action = {
                    feature.enabled = !feature.enabled
                    autoreloadCell.icon.image = UIImage(named: feature.enabled ? "auto-updates-on" : "auto-updates-off", in: bundle, compatibleWith: nil)
                    self.tableView.reloadData()
                    self.open = false
                }
                autoreloadCell.icon.image = UIImage(named: feature.enabled ? "auto-updates-on" : "auto-updates-off", in: bundle, compatibleWith: nil)
                autoreloadCell.selectionStyle = .none
                autoreloadCell.contentView.layer.cornerRadius = 30.0
                autoreloadCell.contentView.clipsToBounds = true
                cells.append(autoreloadCell)
            }
        }
        
        if let feature = RealtimeUpdateFeature.shared {
            if let realtimeUpdateCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                realtimeUpdateCell.action = {
                    feature.enabled = !feature.enabled
                    realtimeUpdateCell.icon.image = UIImage(named: feature.enabled ? "realtime-updates-on" : "realtime-updates-off", in: bundle, compatibleWith: nil)
                    self.tableView.reloadData()
                    self.open = false
                }
                realtimeUpdateCell.icon.image = UIImage(named: feature.enabled ? "realtime-updates-on" : "realtime-updates-off", in: bundle, compatibleWith: nil)
                realtimeUpdateCell.selectionStyle = .none
                realtimeUpdateCell.contentView.layer.cornerRadius = 30.0
                realtimeUpdateCell.contentView.clipsToBounds = true
                cells.append(realtimeUpdateCell)
            }
        }
        
        if let feature = ScreenshotFeature.shared {
            if let screenshotCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
                screenshotCell.action = {
                    self.isHidden = true
                    feature.captureScreenshot(name: "NewScreenhot", success: {
                        print("Success")
                    }, errorHandler: { (error) in
                        print("Error uploading screenshot - \(error?.localizedDescription ?? "Unknown")")
                    })
                    self.isHidden = false
                    self.open = false
                }
                screenshotCell.icon.image = UIImage(named: "screenshot", in: bundle, compatibleWith: nil)
                screenshotCell.selectionStyle = .none
                screenshotCell.layer.cornerRadius = 30.0
                screenshotCell.clipsToBounds = true
                cells.append(screenshotCell)
            }
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
