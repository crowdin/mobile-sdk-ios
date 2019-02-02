//
//  String.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation

extension String {
	public var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}

extension String {
    static var dot: String { return "." }
}
