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

    // MARK: - Table Sections

    private enum Section: Int, CaseIterable {
        case testing
        case language
    }

    private enum TestingRow: Int, CaseIterable {
        case localizationTesting
        case runtimePreview

        var title: String {
            switch self {
            case .localizationTesting: return "Localization Testing"
            case .runtimePreview:      return "Runtime Preview"
            }
        }
    }

    enum Strings: String {
        case settings
        case language
        case auto
        case done
        case localizationTesting = "Localization Testing"
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        localizations.insert(Strings.auto.rawValue.capitalized.localized, at: 0)

        self.title = Strings.settings.rawValue.capitalized.localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Strings.done.rawValue.capitalized.localized,
            style: .done,
            target: self,
            action: #selector(cancelBtnTapped)
        )
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        setupLoadingIndicator()
        self.tableView.reloadData()
    }

    // MARK: - Actions

    @objc func cancelBtnTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .testing:  return nil
        case .language: return Strings.language.rawValue.capitalized.localized
        case .none:     return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .testing:  return TestingRow.allCases.count
        case .language: return localizations.count
        case .none:     return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        switch Section(rawValue: indexPath.section) {
        case .testing:
            let row = TestingRow(rawValue: indexPath.row) ?? .localizationTesting
            cell.textLabel?.text = row.title
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .disclosureIndicator

        case .language:
            cell.textLabel?.text = localizations[indexPath.row]
            cell.textLabel?.textColor = .label
            let currentLocalization = CrowdinSDK.currentLocalization
            cell.accessoryType = .none
            if currentLocalization == nil && indexPath.row == 0 {
                cell.accessoryType = .checkmark
            } else if currentLocalization == localizations[indexPath.row] {
                cell.accessoryType = .checkmark
            }

        case .none:
            break
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section) {
        case .testing:
            switch TestingRow(rawValue: indexPath.row) {
            case .localizationTesting, .none:
                navigationController?.pushViewController(LocalizationTestingVC(), animated: true)
            case .runtimePreview:
                navigationController?.pushViewController(LocalizationRuntimeVC(), animated: true)
            }

        case .language:
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

        case .none:
            break
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
