//
//  CustomProvider.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 2/2/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation
import CrowdinSDK

class CustomProvider: LocalizationProvider {
    func set(localization: String?) {
        self.localization = localization ?? "en"
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
    }

    required init(localization: String?) {
        self.localization = localization ?? "en"
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
    }
    var localization: String
    
    var allLocalization: [String: Any] = [:]
    var localizations: [String] = []
    
    var localizationDict: [String : String] = [:]
    
    func deintegrate() {
        
    }
    
    required init() {
        self.localization = "en"
        self.allLocalization = [
			"en": [
				/* 인트로 */
				"intro.title" : "Keep your\nEOS\nin the safest wallet [en][custom]",
				
				/* 로그인 */
				"login.facebook" : "Sign in with Facebook [en][custom]",
				"login.kakao" : "Sign in with Kakao [en][custom]",
				"login.google" : "Sign in with Google [en][custom]",
				"login.email" : "Sign in with Email [en][custom]",
				"login.none" : "Skip sign in [en][custom]",

            ],
			"ko": [
				/* 인트로 */
				"intro.title" : "Keep your\nEOS\nin the safest wallet [ko][custom]",
				
				/* 로그인 */
				"login.facebook" : "Sign in with Facebook [ko][custom]",
				"login.kakao" : "Sign in with Kakao [ko][custom]",
				"login.google" : "Sign in with Google [ko][custom]",
				"login.email" : "Sign in with Email [ko][custom]",
				"login.none" : "Skip sign in [ko][custom]",

            ]
        ]
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
        
        DispatchQueue(label: "localization").async {
            Thread.sleep(forTimeInterval: 5)
            self.localizations = ["en", "ko"]
            self.allLocalization = [
				"en": [
					/* 인트로 */
					"intro.title" : "Keep your\nEOS\nin the safest wallet [en][new]",
					
					/* 로그인 */
					"login.facebook" : "Sign in with Facebook [en][new]",
					"login.kakao" : "Sign in with Kakao [en][new]",
					"login.google" : "Sign in with Google [en][new]",
					"login.email" : "Sign in with Email [en][new]",
					"login.none" : "Skip sign in [en][new]",

                ],
				"ko": [/* 인트로 */
					"intro.title" : "Keep your\nEOS\nin the safest wallet [ko][new]",
					
					/* 로그인 */
					"login.facebook" : "Sign in with Facebook [ko][new]",
					"login.kakao" : "Sign in with Kakao [ko][new]",
					"login.google" : "Sign in with Google [ko][new]",
					"login.email" : "Sign in with Email [ko][new]",
					"login.none" : "Skip sign in [ko][new]",
                ]
            ]
            DispatchQueue.main.async {
                self.refresh()
                CrowdinSDK.reloadUI()
            }
        }
    }
    func refresh() {
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
    }
}
