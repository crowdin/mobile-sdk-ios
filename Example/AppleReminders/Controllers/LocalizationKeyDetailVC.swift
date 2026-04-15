//
//  LocalizationKeyDetailVC.swift
//  AppleReminders
//
//  Created by Serhii Londar on 31.03.2026.
//

import UIKit
import CrowdinSDK

// MARK: - LocalizationParam

/// Represents a single format specifier detected inside a localization string,
/// together with the current user-supplied test value.
struct LocalizationParam {

    // MARK: - Parameter Type

    enum ParamType: String {
        case string    = "String"
        case int       = "Int"
        case uInt      = "UInt"
        case double    = "Double"
        case character = "Char"

        var keyboardType: UIKeyboardType {
            switch self {
            case .string, .character: return .default
            case .int, .uInt:         return .numberPad
            case .double:             return .decimalPad
            }
        }
    }

    // MARK: - Properties

    let position: Int       // 1-based display index
    let type: ParamType
    var value: String = ""

    var placeholder: String { "Enter \(type.rawValue)" }

    /// Returns a `CVarArg` representation of the current value, using the
    /// appropriate type cast. Falls back to a zero / empty value when the
    /// input cannot be parsed.
    var cvarArg: CVarArg {
        switch type {
        case .string, .character:
            return value as CVarArg
        case .int:
            return (Int(value) ?? 0) as CVarArg
        case .uInt:
            return (UInt(value) ?? 0) as CVarArg
        case .double:
            return (Double(value) ?? 0.0) as CVarArg
        }
    }
}

// MARK: - LocalizationKeyDetailVC

/// Detail screen that lets the developer test a single localization key.
///
/// **Strings tab** — shows the raw format string, dynamically generates one
/// text-field input per detected format specifier, and displays the final
/// translated result once all fields are filled in.
///
/// **Plurals tab** — shows every plural form grouped by variable, provides one
/// integer input per variable (one for simple keys, two or more for complex
/// multi-variable keys like `files_in_folders_count`), and displays the live
/// result once all counts are entered.
///
/// Supports three stringsdict patterns:
/// - **Simple**: one variable, single count → `reminders_count`
/// - **Multi-variable**: two or more independent variables → `files_in_folders_count`
/// - **Nested/dependent**: one variable whose forms embed another variable →
///   `tasks_completed_in_days`
final class LocalizationKeyDetailVC: UITableViewController {

    // MARK: - Key Type

    enum KeyType {
        case string
        case plural
    }

    // MARK: - Sections

    private enum Section: Int, CaseIterable {
        case key         = 0
        case format      = 1
        case parameters  = 2
        case translation = 3

        var headerTitle: String {
            switch self {
            case .key:          return "Key"
            case .format:       return "Format"
            case .parameters:   return "Parameters"
            case .translation:  return "Translation"
            }
        }
    }

    // MARK: - Plural form row

    /// Flat representation of a single plural form for display in the Format section.
    private struct PluralFormRow {
        let variableName: String
        let rule: String
        let format: String
    }

    // MARK: - Properties

    let key: String
    let type: KeyType
    let source: LocalizationDataSource

    // Strings
    private var rawFormat: String?
    private var params: [LocalizationParam] = []

    // Plurals
    private let ruleOrder = ["zero", "one", "two", "few", "many", "other"]
    private var pluralEntry: CrowdinPluralEntry?
    private var pluralCounts: [String] = []     // one slot per variable
    private var pluralFormRows: [PluralFormRow] = []

    // MARK: - Init

    init(key: String, type: KeyType, source: LocalizationDataSource = .crowdin) {
        self.key = key
        self.type = type
        self.source = source
        super.init(style: .insetGrouped)
        loadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        addSourceBadgeIfNeeded()
        tableView.register(UITableViewCell.self,    forCellReuseIdentifier: "InfoCell")
        tableView.register(TextFieldCell.self,      forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.register(TranslationResultCell.self, forCellReuseIdentifier: TranslationResultCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Title & badge

    private func updateTitle() {
        switch source {
        case .crowdin: title = "Key Detail (Crowdin)"
        case .bundle:  title = "Key Detail (Local)"
        }
    }

    /// When the Crowdin source is selected but no remote data has been
    /// downloaded for this key, shows a nav bar prompt so the developer
    /// understands the display is falling back to the local bundle.
    private func addSourceBadgeIfNeeded() {
        guard source == .crowdin else { return }
        let hasCrowdinData: Bool
        switch type {
        case .string: hasCrowdinData = CrowdinSDK.hasCrowdinString(forKey: key)
        case .plural: hasCrowdinData = CrowdinSDK.hasCrowdinPlural(forKey: key)
        }
        if !hasCrowdinData {
            navigationItem.prompt = "⚠ No Crowdin data — showing bundle fallback"
        }
    }

    // MARK: - Data Loading

    private func loadData() {
        switch type {
        case .string:
            rawFormat = CrowdinSDK.rawString(forKey: key, from: source)
            params = parseParams(from: rawFormat ?? "")

        case .plural:
            pluralEntry = CrowdinSDK.pluralEntry(forKey: key, from: source)
            let varCount = pluralEntry?.variables.count ?? 1
            pluralCounts = Array(repeating: "", count: varCount)

            pluralFormRows = pluralEntry?.variables.flatMap { variable in
                ruleOrder.compactMap { rule -> PluralFormRow? in
                    guard let format = variable.forms[rule] else { return nil }
                    return PluralFormRow(variableName: variable.name,
                                        rule: rule,
                                        format: format)
                }
            } ?? []
        }
    }

    // MARK: - Format Specifier Parsing

    /// Scans `format` for printf-style format specifiers and returns a
    /// `LocalizationParam` for each one, preserving document order.
    private func parseParams(from format: String) -> [LocalizationParam] {
        let pattern = "(?<!%)%(?:\\d+\\$)?[-+ #0]?\\d*(?:\\.\\d+)?(?:hh?|ll?|[qztj])?([dioux@fFeEgGaAcs])"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }

        let nsFormat = format as NSString
        let matches = regex.matches(in: format, range: NSRange(location: 0, length: nsFormat.length))

        return matches.enumerated().map { index, match in
            let specRange = match.range(at: 1)
            let spec = specRange.location != NSNotFound
                ? nsFormat.substring(with: specRange).lowercased()
                : "@"

            let paramType: LocalizationParam.ParamType
            switch spec {
            case "d", "i":                   paramType = .int
            case "u", "o", "x":              paramType = .uInt
            case "f", "e", "g", "a":         paramType = .double
            case "c":                        paramType = .character
            default:                         paramType = .string
            }

            return LocalizationParam(position: index + 1, type: paramType)
        }
    }

    // MARK: - Translation Computation

    private func computeTranslation() -> (text: String, isPending: Bool) {
        switch type {

        case .string:
            guard !params.isEmpty else {
                let result = localizedString(forKey: key)
                return (result == key ? "No translation found for this key." : result, false)
            }
            guard params.allSatisfy({ !$0.value.isEmpty }) else {
                return ("Fill in all \(params.count) parameter(s) above to see the translation.", true)
            }
            let format = localizedString(forKey: key)
            let args = params.map { $0.cvarArg }
            return (String(format: format, arguments: args), false)

        case .plural:
            guard pluralCounts.allSatisfy({ !$0.isEmpty }) else {
                let varCount = pluralEntry?.variables.count ?? 1
                let msg = varCount == 1
                    ? "Enter a count above to see the translation."
                    : "Enter all \(varCount) counts above to see the translation."
                return (msg, true)
            }
            let parsedCounts = pluralCounts.compactMap { Int($0) }
            guard parsedCounts.count == pluralCounts.count else {
                return ("All counts must be valid integers.", true)
            }

            // ── System path ──────────────────────────────────────────────────
            // Get the localized format key (e.g. "%#@reminders@"). When the
            // bundle (or Crowdin) stringsdict is available, String(format:) will
            // automatically resolve all %#@variable@ specifiers including nested
            // ones, using the arguments in order.
            //
            // IMPORTANT: Pass the SDK's locale so that Foundation applies the
            // correct CLDR plural rules for the active language, not the device
            // locale (Locale.current). Without this, a device set to English
            // would use English rules (21 → "other") even when displaying
            // Ukrainian translations where 21 → "one".
            let sdkLang = CrowdinSDK.currentLocalization?.components(separatedBy: "-").first
                ?? Locale.current.languageCode ?? "en"
            let pluralLocale = Locale(identifier: sdkLang)
            let formatTemplate = localizedString(forKey: key)
            if formatTemplate != key, formatTemplate.contains("%#@") {
                let args: [CVarArg] = parsedCounts.map { $0 as CVarArg }
                return (String(format: formatTemplate, locale: pluralLocale, arguments: args), false)
            }
            // Simple (non-stringsdict) format returned — apply first count.
            if formatTemplate != key {
                return (String(format: formatTemplate, locale: pluralLocale, parsedCounts[0]), false)
            }

            // ── Manual fallback ───────────────────────────────────────────────
            // System path returned the key unchanged; no stringsdict available.
            // Build the translation by selecting forms from the parsed entry and
            // recursively expanding variable references.
            if let entry = pluralEntry {
                return (applyManualPluralFallback(entry: entry, counts: parsedCounts), false)
            }
            return ("No translation found for this key.", false)
        }
    }

    // MARK: - Manual Plural Fallback

    /// Selects the correct plural form for each variable based on CLDR rules and
    /// recursively expands nested variable references in the format key.
    ///
    /// This fallback is only invoked when the system path (stringsdict via
    /// `String(format:)`) is unavailable — e.g. when Crowdin has downloaded
    /// `.strings` but not `.stringsdict` data.
    ///
    /// Handles all three stringsdict patterns:
    /// - Simple single-variable (`%#@reminders@`)
    /// - Multi-variable (`%1$#@files@ in %2$#@folders@`)
    /// - Nested/dependent (`%#@tasks@` where `tasks` forms embed `%#@days@`)
    private func applyManualPluralFallback(entry: CrowdinPluralEntry, counts: [Int]) -> String {
        guard !entry.variables.isEmpty else { return "No plural forms available." }
        let langCode = CrowdinSDK.currentLocalization?.components(separatedBy: "-").first
            ?? Locale.current.languageCode ?? "en"

        // Map variable name → (selected raw form, driving count)
        var selectedForms: [String: (form: String, count: Int)] = [:]
        for (i, variable) in entry.variables.enumerated() {
            let count = i < counts.count ? counts[i] : 0
            let rule  = selectPluralRule(count: count, languageCode: langCode)
            let priority: [String] = count == 0
                ? ["zero", rule, "other", "one", "many", "few", "two"]
                : [rule, "other", "one", "many", "few", "two", "zero"]
            let form = priority.compactMap { variable.forms[$0] }.first ?? "–"
            selectedForms[variable.name] = (form: form, count: count)
        }

        /// Recursively expand `%#@varName@` (and positional `%N$#@varName@`)
        /// references, then substitute integer specifiers with the variable's count.
        func expand(_ template: String, depth: Int = 0) -> String {
            guard depth < entry.variables.count + 2 else { return template }
            var result = template
            for (varName, info) in selectedForms {
                let simpleRef = "%#@\(varName)@"
                let positionalPattern = "%\\d+\\$#@\(NSRegularExpression.escapedPattern(for: varName))@"

                let hasSimple     = result.contains(simpleRef)
                let hasPositional = result.range(of: positionalPattern, options: .regularExpression) != nil
                guard hasSimple || hasPositional else { continue }

                // Recursively expand any nested variable references inside this form
                let innerExpanded = expand(info.form, depth: depth + 1)
                // Replace integer specifiers with the variable's own count
                let countApplied  = applyIntegerSpecifiers(count: info.count, to: innerExpanded)

                if hasSimple {
                    result = result.replacingOccurrences(of: simpleRef, with: countApplied)
                }
                if hasPositional,
                   let rx = try? NSRegularExpression(pattern: positionalPattern) {
                    result = rx.stringByReplacingMatches(
                        in: result,
                        range: NSRange(result.startIndex..., in: result),
                        withTemplate: NSRegularExpression.escapedTemplate(for: countApplied)
                    )
                }
            }
            return result
        }

        return expand(entry.formatKey)
    }

    /// Replaces printf integer specifiers (`%d`, `%ld`, `%u`, etc.) in
    /// `template` with the literal `count` string.
    private func applyIntegerSpecifiers(count: Int, to template: String) -> String {
        let pattern = "%(?:\\d+\\$)?[-+ #0]?\\d*(?:\\.\\d+)?(?:hh?|ll?|[qztj])?[diouxX]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return template.replacingOccurrences(of: "%d", with: "\(count)")
        }
        return regex.stringByReplacingMatches(
            in: template,
            range: NSRange(template.startIndex..., in: template),
            withTemplate: "\(count)"
        )
    }

    /// Returns the CLDR plural rule name for `count` in the given language.
    private func selectPluralRule(count: Int, languageCode: String) -> String {
        switch languageCode {
        // Slavic languages (Russian, Ukrainian, Belarusian, Serbian, etc.)
        case "ru", "uk", "be", "sr", "bs", "hr", "sh":
            let mod10  = count % 10
            let mod100 = count % 100
            if mod10 == 1 && mod100 != 11                               { return "one"  }
            if (2...4).contains(mod10) && !(12...14).contains(mod100)  { return "few"  }
            if mod10 == 0 || (5...9).contains(mod10) || (11...14).contains(mod100) { return "many" }
            return "other"

        // Polish
        case "pl":
            let mod10  = count % 10
            let mod100 = count % 100
            if count == 1                                               { return "one"  }
            if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "few"  }
            return "other"

        // Czech / Slovak
        case "cs", "sk":
            if count == 1              { return "one" }
            if (2...4).contains(count) { return "few" }
            return "other"

        // Arabic
        case "ar":
            let mod100 = count % 100
            if count == 0                          { return "zero"  }
            if count == 1                          { return "one"   }
            if count == 2                          { return "two"   }
            if (3...10).contains(mod100)           { return "few"   }
            if (11...99).contains(mod100)          { return "many"  }
            return "other"

        // French (one for 0 and 1)
        case "fr", "ff", "kab":
            return count <= 1 ? "one" : "other"

        // Japanese, Chinese, Korean, etc. (no plural forms)
        case "ja", "zh", "ko", "vi", "th", "id", "ms":
            return "other"

        // Default: Germanic / Romance two-form rule (one | other)
        default:
            return count == 1 ? "one" : "other"
        }
    }

    // MARK: - Source helper

    /// Returns a localized string for `key` via the selected data source.
    private func localizedString(forKey key: String) -> String {
        switch source {
        case .crowdin:
            return key.cw_localized
        case .bundle:
            return CrowdinSDK.rawString(forKey: key, from: .bundle) ?? key
        }
    }
}

// MARK: - UITableViewDataSource

extension LocalizationKeyDetailVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .key:          return 1
        case .format:
            switch type {
            case .string: return 1
            case .plural: return max(pluralFormRows.count, 1)
            }
        case .parameters:
            switch type {
            case .string: return max(params.count, 1)
            case .plural: return max(pluralCounts.count, 1)
            }
        case .translation: return 1
        case .none:         return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let s = Section(rawValue: section) else { return nil }
        if s == .parameters, type == .plural {
            let count = pluralEntry?.variables.count ?? 1
            return count > 1 ? "Parameters — \(count) counts" : "Parameters"
        }
        return s.headerTitle
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .key:          return makeKeyCell(for: indexPath)
        case .format:       return makeFormatCell(for: indexPath)
        case .parameters:   return makeParameterCell(for: indexPath)
        case .translation:  return makeTranslationCell(for: indexPath)
        case .none:         return UITableViewCell()
        }
    }

    // MARK: Key cell

    private func makeKeyCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = key
        config.textProperties.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        config.textProperties.numberOfLines = 0
        cell.contentConfiguration = config
        return cell
    }

    // MARK: Format cell(s)

    private func makeFormatCell(for indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .string:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            if let format = rawFormat {
                config.text = format
                config.textProperties.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
                config.textProperties.numberOfLines = 0
            } else {
                config.text = "No format string found for this key."
                config.textProperties.color = .secondaryLabel
            }
            cell.contentConfiguration = config
            return cell

        case .plural:
            if pluralFormRows.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = "No plural forms found for this key."
                config.textProperties.color = .secondaryLabel
                cell.contentConfiguration = config
                return cell
            }
            let row  = pluralFormRows[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = row.format
            config.textProperties.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            config.textProperties.numberOfLines = 0
            // Show "variableName • Rule" for multi-variable keys
            let hasMultiple = (pluralEntry?.variables.count ?? 0) > 1
            config.secondaryText = hasMultiple
                ? "\(row.variableName) • \(row.rule.capitalized)"
                : row.rule.capitalized
            config.secondaryTextProperties.color = .systemBlue
            config.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .semibold)
            cell.contentConfiguration = config
            return cell
        }
    }

    // MARK: Parameter input cell(s)

    private func makeParameterCell(for indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .string:
            if params.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = "No parameters — this string needs no input."
                config.textProperties.color = .secondaryLabel
                cell.contentConfiguration = config
                return cell
            }
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
            let param = params[indexPath.row]
            cell.configure(
                label: "Param \(param.position) (\(param.type.rawValue))",
                placeholder: param.placeholder,
                keyboardType: param.type.keyboardType,
                currentValue: param.value
            ) { [weak self] newValue in
                self?.params[indexPath.row].value = newValue
                self?.reloadTranslation()
            }
            return cell

        case .plural:
            guard indexPath.row < pluralCounts.count else {
                return tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            }
            let idx      = indexPath.row
            let varName  = pluralEntry?.variables[safe: idx]?.name ?? "count \(idx + 1)"
            let label    = pluralEntry?.isComplex == true
                ? "\(varName) count"   // e.g. "files count", "folders count"
                : "Count"
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
            cell.configure(
                label: label,
                placeholder: "Enter integer",
                keyboardType: .numberPad,
                currentValue: pluralCounts[idx]
            ) { [weak self] newValue in
                self?.pluralCounts[idx] = newValue
                self?.reloadTranslation()
            }
            return cell
        }
    }

    // MARK: Translation result cell

    private func makeTranslationCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TranslationResultCell.reuseIdentifier, for: indexPath) as! TranslationResultCell
        let result = computeTranslation()
        cell.configure(text: result.text, isPending: result.isPending)
        return cell
    }

    // MARK: Helpers

    private func reloadTranslation() {
        let ip = IndexPath(row: 0, section: Section.translation.rawValue)
        tableView.reloadRows(at: [ip], with: .none)
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - TextFieldCell

/// Table view cell that presents a descriptive label and an editable text field
/// side by side. The caller receives every text-change via the `onChange`
/// callback.
final class TextFieldCell: UITableViewCell {

    static let reuseIdentifier = "TextFieldCell"

    private var onChange: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textAlignment = .right
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = .label
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Setup

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    // MARK: Configuration

    func configure(
        label: String,
        placeholder: String,
        keyboardType: UIKeyboardType,
        currentValue: String,
        onChange: @escaping (String) -> Void
    ) {
        titleLabel.text = label
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.text = currentValue.isEmpty ? nil : currentValue
        self.onChange = onChange
    }

    // MARK: Actions

    @objc private func textChanged() {
        onChange?(textField.text ?? "")
    }

    // MARK: Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        textField.text = nil
        textField.placeholder = nil
        onChange = nil
    }
}

// MARK: - TranslationResultCell

/// Table view cell that shows the computed translation result.
/// Uses a muted secondary colour when a result is not yet available
/// (i.e. waiting for parameter input).
final class TranslationResultCell: UITableViewCell {

    static let reuseIdentifier = "TranslationResultCell"

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            resultLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            resultLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Configuration

    func configure(text: String, isPending: Bool) {
        resultLabel.text = text
        resultLabel.textColor = isPending ? .secondaryLabel : .label
    }

    // MARK: Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        resultLabel.text = nil
        resultLabel.textColor = .label
    }
}
