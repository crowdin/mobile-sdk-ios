//
//  File.swift
//
//
//  Created by Serhii Londar on 03.10.2022.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

protocol CrowdinLogCellPresentation {
    var log: CrowdinLog { get }
    var date: String { get }
    var type: String { get }
    var message: String { get }
    var textColor: UIColor { get }
    var isShowArrow: Bool { get }
    var attributedText: NSAttributedString? { get }
}

final class CrowdinLogCellViewModel: CrowdinLogCellPresentation {
    private static var dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss dd/MM/yyyy"
        return dateFormatter
    }()

    let log: CrowdinLog

    init(log: CrowdinLog) {
        self.log = log
    }

    var date: String {
        CrowdinLogCellViewModel.dateFormatter.string(from: log.date)
    }

    var type: String {
        log.type.rawValue
    }

    var message: String {
        log.message
    }

    var textColor: UIColor {
        log.type.color
    }

    var isShowArrow: Bool {
        attributedText != nil
    }

    var attributedText: NSAttributedString? {
        log.attributedDetails
    }
}

#endif
