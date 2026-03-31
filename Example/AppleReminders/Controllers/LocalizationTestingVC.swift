//
//  LocalizationTestingVC.swift
//  AppleReminders
//
//  Created by Serhii Londar on 31.03.2026.
//

import UIKit
import CrowdinSDK

// MARK: - LocalizationTestingVC

/// Root screen for localization testing.
/// Displays all downloaded localization keys split into two tabs — Strings and
/// Plurals — and lets the developer drill into each key to test its translation
/// with arbitrary parameter values.
final class LocalizationTestingVC: UIViewController {

    // MARK: - Tab

    enum Tab: Int, CaseIterable {
        case strings = 0
        case plurals = 1

        var title: String {
            switch self {
            case .strings: return "Strings"
            case .plurals: return "Plurals"
            }
        }
    }

    // MARK: - State

    private var currentTab: Tab = .strings
    private var allKeys: [String] = []
    private var filteredKeys: [String] = []
    private var downloadHandlerId: Int?

    // MARK: - UI

    private lazy var segmentedControl: UISegmentedControl = {
        let items = Tab.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search keys"
        bar.searchBarStyle = .minimal
        bar.delegate = self
        return bar
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "KeyCell")
        tv.dataSource = self
        tv.delegate = self
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No localization data available.\nMake sure CrowdinSDK is initialized and a localization has been downloaded."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Localization Testing"
        view.backgroundColor = .systemBackground
        setupLayout()
        loadKeys()

        downloadHandlerId = CrowdinSDK.addDownloadHandler { [weak self] in
            DispatchQueue.main.async { self?.loadKeys() }
        }
    }

    deinit {
        if let id = downloadHandlerId {
            CrowdinSDK.removeDownloadHandler(id)
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [segmentedControl, searchBar])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Data

    private func loadKeys() {
        switch currentTab {
        case .strings: allKeys = CrowdinSDK.allStringKeys
        case .plurals: allKeys = CrowdinSDK.allPluralKeys
        }
        applyFilter(query: searchBar.text)
    }

    private func applyFilter(query: String?) {
        if let query = query, !query.isEmpty {
            filteredKeys = allKeys.filter { $0.localizedCaseInsensitiveContains(query) }
        } else {
            filteredKeys = allKeys
        }
        let noData = allKeys.isEmpty
        tableView.isHidden = noData
        emptyLabel.isHidden = !noData
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func tabChanged(_ sender: UISegmentedControl) {
        currentTab = Tab(rawValue: sender.selectedSegmentIndex) ?? .strings
        searchBar.text = nil
        loadKeys()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension LocalizationTestingVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredKeys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath)
        let key = filteredKeys[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = key
        config.textProperties.font = .monospacedSystemFont(ofSize: 14, weight: .regular)

        switch currentTab {
        case .strings:
            config.secondaryText = CrowdinSDK.rawString(forKey: key) ?? "–"
        case .plurals:
            let forms = CrowdinSDK.pluralForms(forKey: key)
            config.secondaryText = forms["other"] ?? forms["one"] ?? forms["few"] ?? forms.values.first ?? "–"
        }

        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = filteredKeys[indexPath.row]
        let type: LocalizationKeyDetailVC.KeyType = currentTab == .strings ? .string : .plural
        let detailVC = LocalizationKeyDetailVC(key: key, type: type)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension LocalizationTestingVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        applyFilter(query: nil)
    }
}
