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
		return NSLocalizedString(self, comment: String.empty)
	}
}

extension String {
	var isFormated: Bool {
		return formatTypesRegEx.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).count > 0
	}
}

extension String {
    static let dot = "."
    static let empty = ""
    static let space = " "
    static let enter = "\n"
    static let pathDelimiter = "/"
}

extension NSString {
	func splitBy(ranges: [NSRange]) -> [String] {
		var values = [String]()
		for index in 0...ranges.count - 1 {
			let range = ranges[index]
			guard range.location != NSNotFound else { continue }
			if index == 0 {
				if range.location == 0 { continue }
				guard self.isValid(range: range) else { continue }
				values.append(self.substring(with: NSRange(location: 0, length: range.location)))
			} else {
				let previousRange = ranges[index - 1]
				let location = previousRange.location + previousRange.length
				let substringRange = NSRange(location: location, length: range.location - location)
				guard self.isValid(range: substringRange) else { continue }
				values.append(self.substring(with: substringRange))
			}
			if index == ranges.count - 1 {
				if range.location + range.length == self.length { continue }
				let location = range.location + range.length
				let substringRange = NSRange(location: location, length: self.length - location)
				guard self.isValid(range: substringRange) else { continue }
				values.append(self.substring(with: substringRange))
			}
		}
		return values
	}
	
	private func isValid(range: NSRange) -> Bool {
		return range.location != NSNotFound && range.location + range.length <= length
	}
}
