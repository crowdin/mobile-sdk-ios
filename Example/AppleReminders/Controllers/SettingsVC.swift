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

    // MARK: - Table Sections

    private enum Section: Int, CaseIterable {
        case testing
        case language
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
        case .testing:  return 1
        case .language: return localizations.count
        case .none:     return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        switch Section(rawValue: indexPath.section) {
        case .testing:
            cell.textLabel?.text = Strings.localizationTesting.rawValue
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
            let testingVC = LocalizationTestingVC()
            navigationController?.pushViewController(testingVC, animated: true)

        case .language:
            let localization = localizations[indexPath.row]
            if localization == Strings.auto.rawValue.capitalized.localized {
                CrowdinSDK.currentLocalization = nil
            } else {
                CrowdinSDK.currentLocalization = localization
            }
            tableView.reloadSections(IndexSet(integer: Section.language.rawValue), with: .none)

        case .none:
            break
        }
    }
}
