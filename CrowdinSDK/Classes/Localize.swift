//
//  Localize.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

public class Localize: NSObject {
    class var localizations: [String] { return Bundle.main.localizations }
    
    public class func start() {
        Bundle.swizzle()
        
        let localizationFiles = LocalizationExtractor(locale: "en").files
        print(localizationFiles)
    }
}
