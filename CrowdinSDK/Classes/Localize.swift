//
//  Localize.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

public class Localize: NSObject {
    public class func start() {
        Bundle.swizzle()
    }
}
