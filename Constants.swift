//
//  Constants.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/18/19.
//

import Foundation


let formatTypesRegEx: NSRegularExpression = {
	let pattern_int = "(?:h|hh|l|ll|q|z|t|j)?([dioux])" // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
	let pattern_float = "[aefg]"
	let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
	let precision = "[-+]?\\d*(?:\\.\\d*)?" // precision like in "%1.2f" or "%012.10"
	let reference = "#@([^@]+)@" // reference to NSStringFormatSpecType in .stringsdict
	do {
		return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(pattern_int)|\(pattern_float)|[csp]|\(reference))", options: [.caseInsensitive])
	} catch {
		fatalError("Error building the regular expression used to match string formats")
	}
}()
