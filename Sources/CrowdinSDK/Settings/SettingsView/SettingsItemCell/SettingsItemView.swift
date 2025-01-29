//
//  SettingsItemView.swift
//
//
//  Created by Serhii Londar on 24.08.2022.
//

#if os(iOS) || os(tvOS)

import UIKit

class SettingsItemView: UIView {
    var titleButton = UIButton()
    var statusView = UIView()
    var action: SettingsItemCellAction?

    var title: String = "" {
        didSet {
            titleButton.setTitle(title, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleButton.translatesAutoresizingMaskIntoConstraints = false
        statusView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleButton)
        addSubview(statusView)

        let offset = 8.0
        addConstraints([
            titleButton.topAnchor.constraint(equalTo: topAnchor, constant: offset),
            titleButton.leftAnchor.constraint(equalTo: leftAnchor, constant: offset),
            titleButton.bottomAnchor.constraint(equalTo: statusView.topAnchor),
            titleButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -offset),
            statusView.leftAnchor.constraint(equalTo: leftAnchor, constant: offset),
            statusView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset),
            statusView.rightAnchor.constraint(equalTo: rightAnchor, constant: -offset),
            statusView.heightAnchor.constraint(equalToConstant: 4)
        ])

        titleButton.titleLabel?.textAlignment = .center
        titleButton.backgroundColor = UIColor(white: 233.0 / 255.0, alpha: 1.0)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func callAction(_ sender: AnyObject) {
        action?()
    }
}

#endif
