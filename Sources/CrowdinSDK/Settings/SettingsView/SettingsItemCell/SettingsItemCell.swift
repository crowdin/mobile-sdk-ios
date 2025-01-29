//
//  SettingsItemCell.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/13/19.
//

#if os(iOS) || os(tvOS)

import UIKit

typealias SettingsItemCellAction = () -> Void

class SettingsItemCell: UITableViewCell {
    static var reuseIdentifier: String { String(describing: SettingsItemCell.self) }

    var settingsItemView = SettingsItemView(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        settingsItemView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(settingsItemView)

        addConstraints([
            contentView.topAnchor.constraint(equalTo: settingsItemView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: settingsItemView.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: settingsItemView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: settingsItemView.rightAnchor)
        ])

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
