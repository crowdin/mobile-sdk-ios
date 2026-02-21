//
//  SettingsVC.swift
//  AppleReminders
//
//  Created by Serhii Londar on 25.12.2020.
//  Copyright © 2020 Josh R. All rights reserved.
//

import UIKit
import CrowdinSDK

class SettingsVC: UITableViewController {
    var localizations = CrowdinSDK.allAvailableLocalizations
    private var isLocalizationLoading = false
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    enum Strings: String {
        case settings
        case language
        case auto
        case done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localizations.insert(Strings.auto.rawValue.capitalized.localized, at: 0)
        
        self.title = Strings.settings.rawValue.capitalized.localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.done.rawValue.capitalized.localized, style: .done, target: self, action: #selector(cancelBtnTapped))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        setupLoadingIndicator()
        self.tableView.reloadData()
    }
    
    @objc func cancelBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Strings.language.rawValue.capitalized.localized
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        localizations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")!
        cell.textLabel?.text = localizations[indexPath.row]
        let localization = CrowdinSDK.currentLocalization
        cell.accessoryType = .none
        if localization == nil && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else if localization == localizations[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !isLocalizationLoading else { return }
        
        let localization = localizationCode(for: indexPath)
        guard localization != CrowdinSDK.currentLocalization else {
            self.tableView.reloadData()
            return
        }
        
        setLocalizationLoading(true)
        CrowdinSDK.setCurrentLocalization(localization) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLocalizationLoading(false)
                
                if let error = error {
                    self.alert(message: error.localizedDescription, title: "Error")
                    self.tableView.reloadData()
                    return
                }
                
                self.reloadLocalizedUI()
            }
        }
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setLocalizationLoading(_ loading: Bool) {
        isLocalizationLoading = loading
        tableView.allowsSelection = !loading
        tableView.isUserInteractionEnabled = !loading
        navigationItem.rightBarButtonItem?.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func localizationCode(for indexPath: IndexPath) -> String? {
        return indexPath.row == 0 ? nil : localizations[indexPath.row]
    }
    
    private func reloadLocalizedUI() {
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.reloadLocalizedUI()
        } else {
            tableView.reloadData()
        }
    }
}
