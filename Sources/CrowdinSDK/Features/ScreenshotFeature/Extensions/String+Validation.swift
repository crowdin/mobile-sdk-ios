//
//  CGRect.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

extension String {
    func validateScreenshotName() -> Bool {
        let trimmedText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedText.isEmpty && trimmedText.range(of: "[\\\\/:*?\"<>|]", options: .regularExpression) == nil
    }
    
    static func screenshotValidationError() -> String {
        "Screenshot name should not be empty and not contain special characters - [\\\\/:*?\"<>|]"
    }
}

