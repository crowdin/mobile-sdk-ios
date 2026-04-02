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
///
/// A **Source** control lets you switch between:
/// - **Crowdin** — translations downloaded from Crowdin (remote data).
/// - **Local**   — translations bundled inside the app (`.strings` / `.stringsdict`).
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
    private var currentSource: LocalizationDataSource = .crowdin
    private var allKeys: [String] = []
    private var filteredKeys: [String] = []
    private var downloadHandlerId: Int?

    // MARK: - UI

    private lazy var tabControl: UISegmentedControl = {
        let items = Tab.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var sourceControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Crowdin", "Local"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(sourceChanged(_:)), for: .valueChanged)
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
        let headerStack = UIStackView(arrangedSubviews: [tabControl, sourceControl, searchBar])
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
        case .strings: allKeys = CrowdinSDK.allStringKeys(from: currentSource)
        case .plurals: allKeys = CrowdinSDK.allPluralKeys(from: currentSource)
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
        emptyLabel.text = noData ? emptyMessage : nil
        tableView.reloadData()
    }

    // MARK: - Plural preview

    /// Returns a short preview string for the given plural key.
    ///
    /// **Crowdin source** — uses the SDK's live resolution path
    /// (`key.cw_localized` + `String(format:, 1)`) so the cell shows what
    /// Crowdin actually delivers, not the raw bundle form.
    ///
    /// **Local source** — shows the raw "other" / "one" form from the bundle
    /// stringsdict so you can see the unformatted template.
    private func pluralPreview(forKey key: String, source: LocalizationDataSource) -> String {
        switch source {
        case .crowdin:
            // cw_localized returns the NSStringLocalizedFormatKey template
            // (e.g. "%#@reminders@"). String.localizedStringWithFormat lets iOS
            // walk the stringsdict and pick the right form for count 1.
            let template = key.cw_localized
            if template == key {
                // SDK returned the key unchanged — no translation available.
                return "(no Crowdin translation)"
            }
            // Try to resolve the plural with a sample count of 1.
            // This works for simple and multi-variable keys (all args are 1).
            if template.contains("%#@") {
                // Multi-variable: pass as many 1s as there are variables.
                // Prefer the Crowdin entry's count; fall back to the bundle entry
                // (needed when Crowdin has no plural data but cw_localized still
                // resolves via the bundle stringsdict).
                let varCount = CrowdinSDK.pluralEntry(forKey: key, from: .crowdin)?.variables.count
                            ?? CrowdinSDK.pluralEntry(forKey: key, from: .bundle)?.variables.count
                            ?? 1
                let args: [CVarArg] = Array(repeating: 1 as Int, count: varCount)
                return String(format: template, arguments: args)
            }
            return String(format: template, 1)

        case .bundle:
            // Show the raw format string so the developer can see the template.
            let forms = CrowdinSDK.pluralForms(forKey: key, from: .bundle)
            return forms["other"] ?? forms["one"] ?? forms["few"] ?? forms.values.first ?? "–"
        }
    }

    private var emptyMessage: String {
        switch (currentSource, currentTab) {
        case (.crowdin, .plurals):
            return "No plural data downloaded from Crowdin.\nMost distributions ship only .strings files — use the Local tab to browse bundled plurals."
        case (.crowdin, .strings):
            return "No Crowdin translations available.\nMake sure CrowdinSDK is initialized and translations have been downloaded."
        case (.bundle, _):
            return "No in-bundle localization found.\nAdd a Localizable.strings / .stringsdict file for the current language."
        }
    }

    // MARK: - Actions

    @objc private func tabChanged(_ sender: UISegmentedControl) {
        currentTab = Tab(rawValue: sender.selectedSegmentIndex) ?? .strings
        searchBar.text = nil
        loadKeys()
    }

    @objc private func sourceChanged(_ sender: UISegmentedControl) {
        currentSource = sender.selectedSegmentIndex == 0 ? .crowdin : .bundle
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
            switch currentSource {
            case .crowdin:
                // Show the live SDK-resolved string (what Crowdin actually delivers).
                // Falls back to raw bundle value when no Crowdin translation exists.
                let resolved = key.cw_localized
                config.secondaryText = resolved == key
                    ? (CrowdinSDK.rawString(forKey: key, from: .bundle) ?? "–")
                    : resolved
            case .bundle:
                config.secondaryText = CrowdinSDK.rawString(forKey: key, from: .bundle) ?? "–"
            }
        case .plurals:
            config.secondaryText = pluralPreview(forKey: key, source: currentSource)
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
        let detailVC = LocalizationKeyDetailVC(key: key, type: type, source: currentSource)
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
