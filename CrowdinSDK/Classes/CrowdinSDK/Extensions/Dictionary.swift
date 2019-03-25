//
//  Dictionary.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

extension Dictionary {
	mutating func merge(with dict: [Key : Value]) {
		for (k, v) in dict {
			updateValue(v, forKey: k)
		}
	}
	
	static func += (left: inout [Key : Value], right: [Key : Value]) {
		for (k, v) in right {
			left[k] = v
		}
	}
	
	static func + (left: inout [Key : Value], right: [Key : Value]) -> [Key : Value] {
		var result: [Key : Value] = [:]
		for (k, v) in right {
			result[k] = v
		}
		for (k, v) in left {
			result[k] = v
		}
		return result
	}
}
