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
/// **Plurals tab** — shows every plural form (zero / one / two / few / many /
/// other) with its format string, provides a single integer "Count" input, and
/// displays the translated result.
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

    // MARK: - Properties

    let key: String
    let type: KeyType

    // Strings
    private var rawFormat: String?
    private var params: [LocalizationParam] = []

    // Plurals
    private let ruleOrder = ["zero", "one", "two", "few", "many", "other"]
    private var pluralForms: [(rule: String, format: String)] = []
    private var pluralCount: String = ""

    // MARK: - Init

    init(key: String, type: KeyType) {
        self.key = key
        self.type = type
        super.init(style: .insetGrouped)
        loadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Key Detail"
        tableView.register(UITableViewCell.self,    forCellReuseIdentifier: "InfoCell")
        tableView.register(TextFieldCell.self,      forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.register(TranslationResultCell.self, forCellReuseIdentifier: TranslationResultCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Data Loading

    private func loadData() {
        switch type {
        case .string:
            rawFormat = CrowdinSDK.rawString(forKey: key)
            params = parseParams(from: rawFormat ?? "")

        case .plural:
            let forms = CrowdinSDK.pluralForms(forKey: key)
            pluralForms = ruleOrder.compactMap { rule in
                guard let format = forms[rule] else { return nil }
                return (rule: rule, format: format)
            }
        }
    }

    // MARK: - Format Specifier Parsing

    /// Scans `format` for printf-style format specifiers and returns a
    /// `LocalizationParam` for each one, preserving document order.
    ///
    /// Supported specifiers: `%@`, `%s`, `%d`, `%i`, `%u`, `%o`, `%x`,
    /// `%f`, `%e`, `%g`, `%a` (and their uppercase variants), `%c`.
    /// Optional length modifiers (`h`, `hh`, `l`, `ll`, `q`, `z`, `t`, `j`)
    /// and precision / width components are correctly skipped.
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
            default:                         paramType = .string  // "@", "s"
            }

            return LocalizationParam(position: index + 1, type: paramType)
        }
    }

    // MARK: - Translation Computation

    private func computeTranslation() -> (text: String, isPending: Bool) {
        switch type {

        case .string:
            guard !params.isEmpty else {
                // No parameters — plain lookup.
                let result = key.cw_localized
                return (result == key ? "No translation found for this key." : result, false)
            }
            guard params.allSatisfy({ !$0.value.isEmpty }) else {
                return ("Fill in all \(params.count) parameter(s) above to see the translation.", true)
            }
            let args = params.map { $0.cvarArg }
            return (key.cw_localized(with: args), false)

        case .plural:
            guard !pluralCount.isEmpty else {
                return ("Enter an integer count above to see the translation.", true)
            }
            guard let count = Int(pluralCount) else {
                return ("Count must be a valid integer.", true)
            }
            // Try the standard path first: NSLocalizedString + String(format:).
            let localized = key.cw_localized
            if !localized.contains("%#@") {
                // Simple format string (e.g. "%d items") — apply count directly.
                return (String(format: localized, count), false)
            }
            // The format contains a stringsdict variable reference (%#@…@).
            // Fall back to manually selecting and formatting the correct plural form.
            return (applyPluralFallback(count: count), false)
        }
    }

    /// Manual fallback: pick the appropriate plural form based on a simple
    /// CLDR-style rule for the current locale and format it with `count`.
    private func applyPluralFallback(count: Int) -> String {
        guard !pluralForms.isEmpty else { return "No plural forms available." }

        let langCode = Locale.current.languageCode ?? "en"
        let rule = selectPluralRule(count: count, languageCode: langCode)

        // Find the matching form; fall back through the priority order.
        let priority = [rule, "other", "one", "many", "few", "two", "zero"]
        guard let form = priority.compactMap({ r in pluralForms.first(where: { $0.rule == r }) }).first else {
            return pluralForms.first?.format ?? "–"
        }
        return String(format: form.format, count)
    }

    /// Returns the CLDR plural rule name for `count` in the given language.
    private func selectPluralRule(count: Int, languageCode: String) -> String {
        switch languageCode {
        // Slavic languages (Russian, Ukrainian, Belarusian, Serbian, etc.)
        case "ru", "uk", "be", "sr", "bs", "hr", "sh":
            let mod10  = count % 10
            let mod100 = count % 100
            if mod10 == 1 && mod100 != 11                          { return "one"  }
            if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "few"  }
            if mod10 == 0 || (5...9).contains(mod10) || (11...14).contains(mod100) { return "many" }
            return "other"

        // Polish
        case "pl":
            let mod10  = count % 10
            let mod100 = count % 100
            if count == 1                                          { return "one"  }
            if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "few"  }
            return "other"

        // Czech / Slovak
        case "cs", "sk":
            if count == 1 { return "one" }
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

        // Japanese, Chinese, Korean (no plural forms)
        case "ja", "zh", "ko", "vi", "th", "id", "ms":
            return "other"

        // Default: Germanic / Romance two-form rule (one | other)
        default:
            return count == 1 ? "one" : "other"
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
            case .plural: return max(pluralForms.count, 1)
            }
        case .parameters:
            switch type {
            case .string: return max(params.count, 1)
            case .plural: return 1
            }
        case .translation: return 1
        case .none:         return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.headerTitle
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
            if pluralForms.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = "No plural forms found for this key."
                config.textProperties.color = .secondaryLabel
                cell.contentConfiguration = config
                return cell
            }
            let form = pluralForms[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = form.format
            config.textProperties.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            config.textProperties.numberOfLines = 0
            config.secondaryText = form.rule.capitalized
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
            cell.configure(
                label: "Count",
                placeholder: "Enter integer count",
                keyboardType: .numberPad,
                currentValue: pluralCount
            ) { [weak self] newValue in
                self?.pluralCount = newValue
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
