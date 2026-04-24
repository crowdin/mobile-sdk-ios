//
//  LocalizationRuntimeVC.swift
//  AppleReminders
//
//  Created by Serhii Londar on 01.04.2026.
//

import UIKit
import CrowdinSDK

// MARK: - LocalizationRuntimeVC

/// "Runtime simulation" screen: drives every localization key through the
/// Crowdin SDK translation path and shows the result exactly as the app would
/// produce it at runtime.
///
/// **Strings tab** — each key is resolved via `cw_localized`.  Parametrized
/// strings receive sample values (42 for integers, 3.14 for doubles,
/// "Sample" for strings) so the result is always a complete sentence.
///
/// **Plurals tab** — each key is expanded into one row per *representative
/// count*, chosen to cover every CLDR plural category for the current device
/// language.  Multi-variable keys (e.g. `files_in_folders_count`) additionally
/// show mixed-count combinations so you can see every variable's forms.
final class LocalizationRuntimeVC: UIViewController {

    // MARK: - Tab

    private enum Tab: Int, CaseIterable {
        case strings = 0
        case plurals = 1
        var title: String { self == .strings ? "Strings" : "Plurals" }
    }

    // MARK: - Row model

    struct RuntimeRow {
        let key: String
        let translation: String   // final resolved string shown to the user
        let detail: String        // key + params/count shown to the developer
        let isMissing: Bool       // true when the SDK returned the key unchanged
    }

    // MARK: - State

    private var currentTab: Tab = .strings
    private var allRows: [RuntimeRow] = []
    private var filteredRows: [RuntimeRow] = []
    private var downloadHandlerId: Int?

    // MARK: - Format specifier regex (reused from testing screen)

    private let specifierPattern =
        "(?<!%)%(?:\\d+\\$)?[-+ #0]?\\d*(?:\\.\\d+)?(?:hh?|ll?|[qztj])?([dioux@fFeEgGaAcs])"

    // MARK: - UI

    private lazy var tabControl: UISegmentedControl = {
        let c = UISegmentedControl(items: Tab.allCases.map { $0.title })
        c.selectedSegmentIndex = 0
        c.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        return c
    }()

    private lazy var searchBar: UISearchBar = {
        let b = UISearchBar()
        b.placeholder = "Search keys or translations"
        b.searchBarStyle = .minimal
        b.delegate = self
        return b
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(RuntimeCell.self, forCellReuseIdentifier: RuntimeCell.reuseId)
        tv.dataSource = self
        tv.keyboardDismissMode = .onDrag
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 56
        return tv
    }()

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 15)
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Runtime Preview"
        view.backgroundColor = .systemBackground
        setupLayout()
        rebuild()

        downloadHandlerId = CrowdinSDK.addDownloadHandler { [weak self] in
            DispatchQueue.main.async { self?.rebuild() }
        }
    }

    deinit {
        downloadHandlerId.map { CrowdinSDK.removeDownloadHandler($0) }
    }

    // MARK: - Layout

    private func setupLayout() {
        let header = UIStackView(arrangedSubviews: [tabControl, searchBar])
        header.axis = .vertical
        header.spacing = 4
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    // MARK: - Data

    private func rebuild() {
        switch currentTab {
        case .strings: allRows = buildStringRows()
        case .plurals: allRows = buildPluralRows()
        }
        applyFilter(query: searchBar.text)
    }

    private func applyFilter(query: String?) {
        if let q = query, !q.isEmpty {
            filteredRows = allRows.filter {
                $0.key.localizedCaseInsensitiveContains(q) ||
                $0.translation.localizedCaseInsensitiveContains(q)
            }
        } else {
            filteredRows = allRows
        }
        let empty = filteredRows.isEmpty
        tableView.isHidden = empty
        emptyLabel.isHidden = !empty
        emptyLabel.text = empty ? "No results." : nil
        tableView.reloadData()
    }

    // MARK: - Strings

    private func buildStringRows() -> [RuntimeRow] {
        CrowdinSDK.allStringKeys.map { key in
            let rawFormat = CrowdinSDK.rawString(forKey: key) ?? ""
            let template  = key.cw_localized

            // Skip stringsdict format keys — they contain "%#@varName@" which is
            // an Apple-specific specifier, not a printf specifier. Passing sample
            // args to such templates causes format-type-mismatch console warnings.
            // These keys are already covered by the Plurals tab.
            let isStringsdictFormat = rawFormat.contains("%#@") || template.contains("%#@")

            let translation: String
            let detailSuffix: String

            if isStringsdictFormat {
                // Show the template as-is without trying to format it.
                translation = template == key ? key : template
                detailSuffix = ""
            } else {
                let specifiers = detectSpecifiers(in: rawFormat)
                if specifiers.isEmpty {
                    translation = template == key ? key : template
                    detailSuffix = ""
                } else {
                    let args = specifiers.map { sampleArg(for: $0) }
                    let fmt  = template == key ? rawFormat : template
                    translation = (try? String(format: fmt, arguments: args)) ?? fmt
                    detailSuffix = "  ·  " + specifiers.enumerated()
                        .map { "arg\($0.offset + 1)=\(sampleArgDescription(for: $0.element))" }
                        .joined(separator: ", ")
                }
            }

            return RuntimeRow(
                key: key,
                translation: translation,
                detail: key + detailSuffix,
                isMissing: translation == key
            )
        }
    }

    // MARK: - Plurals

    private func buildPluralRows() -> [RuntimeRow] {
        // Use the SDK's active localization if explicitly set (e.g. "uk"),
        // otherwise fall back to the device language. This ensures we pick
        // representative counts for the language actually being displayed,
        // not the system UI language.
        let sdkLang   = CrowdinSDK.currentLocalization?.components(separatedBy: "-").first
        let lang      = sdkLang ?? Locale.current.languageCode ?? "en"
        let counts    = representativeCounts(for: lang)
        // Locale matching the target language — required by
        // String(format:locale:arguments:) for correct CLDR plural-rule
        // resolution (zero / one / two / few / many / other).
        let pluralLocale = Locale(identifier: lang)

        return CrowdinSDK.allPluralKeys.flatMap { key -> [RuntimeRow] in
            let entry    = CrowdinSDK.pluralEntry(forKey: key, from: .bundle)
                        ?? CrowdinSDK.pluralEntry(forKey: key, from: .crowdin)
            let varCount = entry?.variables.count ?? 1
            let template = key.cw_localized

            // Detect which argument positions expect an NSObject (%@) rather
            // than an integer (%d). Some Crowdin translations use %@ in their
            // plural forms; passing a raw Int for %@ makes the formatter treat
            // the integer value as an object pointer and call
            // respondsToSelector: on it — which crashes.
            // Matches any object-type specifier (%@, %1$@, %-5@, …) but
            // NOT %#@ which is a stringsdict plural reference.
            let objectSpecifier = try? NSRegularExpression(pattern: #"%(?:\d+\$)?[-+ #0-9*]*@"#)
            // When entry is nil we have no type info → default to NSNumber for
            // every position (avoids crash; wrong %d display is acceptable on a
            // debug screen).
            let variableUsesObject: [Bool] = entry.map { e in
                e.variables.map { variable -> Bool in
                    guard let regex = objectSpecifier else { return true }
                    return variable.forms.values.contains { form in
                        let ns = form as NSString
                        return regex.firstMatch(
                            in: form,
                            range: NSRange(location: 0, length: ns.length)
                        ) != nil
                    }
                }
            } ?? Array(repeating: true, count: varCount)

            // Build the count-tuples to test.
            // Single-variable: one row per sample count.
            // Multi-variable: "diagonal" (same count for all vars) +
            //                 cross-pairs of first & last count so every
            //                 combination of one/other extremes is shown.
            let tuples: [[Int]]
            if varCount == 1 {
                tuples = counts.map { [$0] }
            } else {
                var t = counts.map { c in Array(repeating: c, count: varCount) }
                // Add mixed combos: first variable at min, others at max (& vice-versa)
                if let lo = counts.first, let hi = counts.last, lo != hi {
                    var loHi = Array(repeating: hi, count: varCount); loHi[0] = lo
                    var hiLo = Array(repeating: lo, count: varCount); hiLo[0] = hi
                    t.append(contentsOf: [loHi, hiLo])
                }
                tuples = t
            }

            return tuples.map { argCounts in
                let args: [CVarArg] = argCounts.enumerated().map { (index, count) -> CVarArg in
                    // Pass NSNumber for %@ positions so the formatter receives
                    // a proper NSObject rather than a bare integer pointer.
                    let usesObject = index < variableUsesObject.count && variableUsesObject[index]
                    return usesObject ? NSNumber(value: count) : count as CVarArg
                }

                // Format the plural string with the correct locale so that
                // the CLDR plural rules for the target language are applied.
                // Always pass ALL arguments — stringsdict entries may use
                // positional specifiers (%1$#@var@) that require every arg.
                let translation: String
                if template != key {
                    translation = String(format: template, locale: pluralLocale, arguments: args)
                } else {
                    // SDK returned the key — try bundle stringsdict directly.
                    let bundleTemplate = Bundle.main.localizedString(
                        forKey: key, value: nil, table: "Localizable")
                    if bundleTemplate != key {
                        translation = String(format: bundleTemplate, locale: pluralLocale, arguments: args)
                    } else {
                        translation = key    // truly missing
                    }
                }

                let countLabel: String
                if varCount == 1 {
                    countLabel = "count: \(argCounts[0])"
                } else if let vars = entry?.variables {
                    countLabel = vars.enumerated()
                        .map { "\($0.element.name): \(argCounts[$0.offset])" }
                        .joined(separator: ", ")
                } else {
                    countLabel = argCounts.enumerated()
                        .map { "arg\($0.offset + 1): \($0.element)" }
                        .joined(separator: ", ")
                }

                return RuntimeRow(
                    key: key,
                    translation: translation,
                    detail: "\(key)  ·  \(countLabel)",
                    isMissing: translation == key
                )
            }
        }
    }

    // MARK: - CLDR representative counts

    /// Returns a set of integer counts that exercises every CLDR plural
    /// category supported by the given language code.
    private func representativeCounts(for lang: String) -> [Int] {
        switch lang {
        // Slavic: zero · one(1,21,31…) · few(2-4,22-24…) · many(5-9,11-19,25-29…)
        case "ru", "uk", "be", "sr", "bs", "hr", "sh":
            return [0, 1, 2, 5, 11, 21, 22, 25, 100]
        // Polish: one(1) · few(2-4) · other(5+)
        case "pl":
            return [0, 1, 2, 5, 11, 21]
        // Czech / Slovak: one · few(2-4) · other
        case "cs", "sk":
            return [0, 1, 2, 4, 5, 10]
        // Arabic: zero · one · two · few(3-10) · many(11-99) · other(100+)
        case "ar":
            return [0, 1, 2, 3, 11, 100]
        // French: one(0-1) · other
        case "fr", "ff", "kab":
            return [0, 1, 2, 10]
        // Languages with no plural distinction
        case "ja", "zh", "ko", "vi", "th", "id", "ms":
            return [0, 1, 5]
        // Default: one(1) · other
        default:
            return [0, 1, 2, 5]
        }
    }

    // MARK: - Format specifier helpers

    private enum Specifier { case int, uInt, double, string }

    private func detectSpecifiers(in format: String) -> [Specifier] {
        guard let regex = try? NSRegularExpression(pattern: specifierPattern) else { return [] }
        let ns = format as NSString
        return regex.matches(in: format, range: NSRange(location: 0, length: ns.length))
            .compactMap { match -> Specifier? in
                let r = match.range(at: 1)
                guard r.location != NSNotFound else { return .string }
                switch ns.substring(with: r).lowercased() {
                case "d", "i":           return .int
                case "u", "o", "x":     return .uInt
                case "f", "e", "g", "a":return .double
                default:                 return .string
                }
            }
    }

    private func sampleArg(for spec: Specifier) -> CVarArg {
        switch spec {
        case .int:    return 42 as Int
        case .uInt:   return 42 as UInt
        case .double: return 3.14 as Double
        case .string: return "Sample" as String
        }
    }

    private func sampleArgDescription(for spec: Specifier) -> String {
        switch spec {
        case .int:    return "42"
        case .uInt:   return "42"
        case .double: return "3.14"
        case .string: return "\"Sample\""
        }
    }

    // MARK: - Actions

    @objc private func tabChanged(_ sender: UISegmentedControl) {
        currentTab = Tab(rawValue: sender.selectedSegmentIndex) ?? .strings
        searchBar.text = nil
        rebuild()
    }
}

// MARK: - UITableViewDataSource

extension LocalizationRuntimeVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RuntimeCell.reuseId, for: indexPath) as! RuntimeCell
        cell.configure(with: filteredRows[indexPath.row])
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension LocalizationRuntimeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(query: searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        applyFilter(query: nil)
    }
}

// MARK: - RuntimeCell

private final class RuntimeCell: UITableViewCell {

    static let reuseId = "RuntimeCell"

    // The resolved translation — what the user actually sees.
    private let translationLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    // Key + param info — developer context.
    private let detailLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 1
        return l
    }()

    // Coloured dot: green = translated, orange = missing.
    private let dot: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 8),
            v.heightAnchor.constraint(equalToConstant: 8),
        ])
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let textStack = UIStackView(arrangedSubviews: [translationLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [dot, textStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with row: LocalizationRuntimeVC.RuntimeRow) {
        if row.isMissing {
            translationLabel.text = row.translation
            translationLabel.textColor = .systemOrange
            dot.backgroundColor = .systemOrange
        } else {
            translationLabel.text = row.translation
            translationLabel.textColor = .label
            dot.backgroundColor = .systemGreen
        }
        detailLabel.text = row.detail
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        translationLabel.text = nil
        detailLabel.text = nil
    }
}

