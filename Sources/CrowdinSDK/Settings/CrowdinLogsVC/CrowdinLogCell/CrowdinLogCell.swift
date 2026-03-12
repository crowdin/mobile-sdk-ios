//
//  File.swift
//
//
//  Created by Serhii Londar on 03.10.2022.
//

#if os(iOS) || os(tvOS)

import UIKit

final class CrowdinLogCell: UITableViewCell {
    private var dateLabel = UILabel()
    private var typeLabel = UILabel()
    private var messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with viewModel: CrowdinLogCellPresentation) {
        self.dateLabel.text = viewModel.date
        self.typeLabel.text = viewModel.type
        self.typeLabel.textColor = viewModel.textColor
        self.messageLabel.text = viewModel.message

        selectionStyle = .none
        accessoryType = viewModel.isShowArrow ? .disclosureIndicator : .none
    }

    private func setupUI() {
        addViews()
        layoutViews()
        setupViews()
    }

    private func addViews() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
    }

    private func layoutViews() {
        let margins = contentView.layoutMarginsGuide
        contentView.addConstraints([
            dateLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            dateLabel.leftAnchor.constraint(equalTo: margins.leftAnchor),

            typeLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            typeLabel.leftAnchor.constraint(greaterThanOrEqualTo: dateLabel.rightAnchor, constant: 8.0),
            typeLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),

            messageLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8.0),
            messageLabel.leftAnchor.constraint(equalTo: margins.leftAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            messageLabel.rightAnchor.constraint(equalTo: margins.rightAnchor)
        ])
    }

    private func setupViews() {
        typeLabel.textAlignment = .right
        typeLabel.setContentHuggingPriority(.required, for: .horizontal)
        typeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
    }
}

#endif
