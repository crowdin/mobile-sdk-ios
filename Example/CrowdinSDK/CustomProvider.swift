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
    var localizationCompleted: LocalizationProviderHandler = { }
    
    var allLocalization: [String: Any] = [:]
    var localizations: [String] = []
    
    var localizationDict: [String : String] = [:]
    
    func deintegrate() {
        
    }
    
    func setLocalization(_ localization: String?) {
        guard let localization = localization else { return }
        localizationDict = self.allLocalization[localization] as? [String: String] ?? [:]
    }
    
    required init() {
        DispatchQueue(label: "localization").async {
            Thread.sleep(forTimeInterval: 5)
            self.localizations = ["en", "uk"]
            self.allLocalization = [
                "en": [
                    "details_button" : "Button [CUSTOM]",
                    "details_label" : "Label 123 [CUSTOM]",
                    "details_segmentedControl_0" : "Value [CUSTOM]",
                    "details_segmentedControl_1" : "Value1 [CUSTOM]",
                    "details_textfield_placeholder" : "Placeholder [CUSTOM]",
                    "details_title" : "Details Screen [CUSTOM]",
                    "main_show_details_button" : "Show Details [CUSTOM]",
                    "main_title" : "Main Screen [CUSTOM]",
                    "menu_explorer_button_title" : "Explorer [CUSTOM]",
                    "menu_firebase_button_title" : "Firebase [CUSTOM]",
                    "menu_main_button_title" : "Main [CUSTOM]",
                    "menu_settings_button_title" : "Settings [CUSTOM]",
                    "settings_in_bundle" : "In Bundle [CUSTOM]",
                    "settings_in_sdk" : "In SDK [CUSTOM]",
                    "test_key" : "Test [CUSTOM]",
                    "test_parameter" : "Parameter [CUSTOM]",
                    "test_with_format_key" : "Test parameter - %@ [CUSTOM]"
                ],
                "uk": [
                    "details_button" : "Кнопка 123 [CUSTOM]",
                    "details_label" : "Лейбл 12 [CUSTOM]",
                    "details_segmentedControl_0" : "Значення0 [CUSTOM]",
                    "details_segmentedControl_1" : "Значення1 [CUSTOM]",
                    "details_textfield_placeholder" : "Якийсь текст [CUSTOM]",
                    "details_title" : "Деталі [CUSTOM]",
                    "main_show_details_button" : "Показати деталі [CUSTOM]",
                    "main_title" : "Головна [CUSTOM]",
                    "menu_explorer_button_title" : "Перегляд файлів [CUSTOM]",
                    "menu_firebase_button_title" : "Firebase [UA] [CUSTOM]",
                    "menu_main_button_title" : "Головна кнопка [CUSTOM]",
                    "menu_settings_button_title" : "Налаштування [CUSTOM]",
                    "settings_in_bundle" : "У бандлі [CUSTOM]",
                    "settings_in_sdk" : "У СДК [CUSTOM]",
                    "test_key" : "Тест [CUSTOM]",
                    "test_parameter" : "Параметр [CUSTOM]",
                    "test_with_format_key" : "Тестовий параметер - %@ [CUSTOM]"
                ]
            ]
            self.localizationCompleted()
        }
    }
}
