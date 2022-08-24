//
//  SettingsItemCell.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/13/19.
//

import UIKit

typealias SettingsItemCellAction = () -> Void

class SettingsItemCell: UITableViewCell {
    var titleLabel = UILabel()
    var statusView = UIView()
    var action: SettingsItemCellAction?
    var shouldSetupConstraints = true
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusView)
        
        let offset = 8.0
        addConstraints([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: offset),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: offset),
            titleLabel.bottomAnchor.constraint(equalTo: statusView.topAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -offset),
            statusView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: offset),
            statusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -offset),
            statusView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -offset),
            statusView.heightAnchor.constraint(equalToConstant: 4),
        ])
        
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor(white: 233.0 / 255.0 , alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
