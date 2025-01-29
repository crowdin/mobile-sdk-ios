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

        guard viewModel.isShowArrow else {
            return
        }

        accessoryType = .disclosureIndicator
    }

    private func setupUI() {
        addViews()
        layoutViews()
        setupViews()
    }

    private func addViews() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(typeLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
    }

    private func layoutViews() {
        addConstraints([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0),

            typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            typeLabel.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 8.0),
            typeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0),

            messageLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8.0),
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0)
        ])
    }

    private func setupViews() {

    }
}

#endif
