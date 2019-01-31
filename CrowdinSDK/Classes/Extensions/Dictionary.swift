//
//  Dictionary.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

extension Dictionary {
	mutating func merge(dict: [Key: Value]){
		for (k, v) in dict {
			updateValue(v, forKey: k)
		}
	}
}
