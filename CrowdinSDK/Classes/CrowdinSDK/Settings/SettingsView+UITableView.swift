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
        let bundle = Bundle(for: SettingsView.self)
        if let reloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            reloadCell.action = {
                self.open = false
                ForceRefreshLocalizationFeature.refreshLocalization()
            }
            reloadCell.icon.image = UIImage(named: "reload", in: bundle, compatibleWith: nil)
            reloadCell.selectionStyle = .none
            cells.append(reloadCell)
        }
        if let autoreloadCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            autoreloadCell.action = {
                IntervalUpdateFeature.enabled = !IntervalUpdateFeature.enabled
                autoreloadCell.icon.image = UIImage(named: IntervalUpdateFeature.enabled ? "auto-updates-on" : "auto-updates-off", in: bundle, compatibleWith: nil)
                self.tableView.reloadData()
            }
            autoreloadCell.icon.image = UIImage(named: IntervalUpdateFeature.enabled ? "auto-updates-on" : "auto-updates-off", in: bundle, compatibleWith: nil)
            autoreloadCell.selectionStyle = .none
            cells.append(autoreloadCell)
        }
        if let screenshotCell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemCell") as? SettingsItemCell {
            screenshotCell.action = {
                self.open = false
                self.isHidden = true
                ScreenshotFeature().captureScreenshot()
                self.isHidden = false
            }
            screenshotCell.icon.image = UIImage(named: "screenshot", in: bundle, compatibleWith: nil)
            screenshotCell.selectionStyle = .none
            cells.append(screenshotCell)
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
