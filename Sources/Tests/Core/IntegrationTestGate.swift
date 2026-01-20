//
//  IntegrationTestGate.swift
//  Tests
//
//  Created by Serhii Londar on 20.01.2026.
//  Copyright © 2026 Serhii Londar. All rights reserved.
//

import Foundation
import XCTest

enum IntegrationTestGate {
    static let envKey = "RUN_INTEGRATION_TESTS"

    static var isEnabled: Bool {
        let value = ProcessInfo.processInfo.environment[envKey]?.lowercased()
        return value == "1" || value == "true" || value == "yes"
    }
}

class IntegrationTestCase: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            IntegrationTestGate.isEnabled,
            "Integration tests disabled. Set RUN_INTEGRATION_TESTS=1 to enable."
        )
    }
}
