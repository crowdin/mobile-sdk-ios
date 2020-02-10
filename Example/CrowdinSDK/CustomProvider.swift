//
//  CustomProvider.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 2/2/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import Foundation
import CrowdinSDK

class CustomProvider: RemoteLocalizationStorageProtocol {
	func deintegrate() {
		
	}
	
    var name: String = "CustomProvider"
    
    var localization: String = "en"
    
    func fetchData(completion: @escaping LocalizationStorageCompletion, errorHandler: LocalizationStorageError?) {
        
    }
    
    /*
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
                "details_button" : "Button [INITIAL]",
                "details_label" : "Label 123 [INITIAL]",
                "details_segmentedControl_0" : "Value [INITIAL]",
                "details_segmentedControl_1" : "Value1 [INITIAL]",
                "details_textfield_placeholder" : "Placeholder [INITIAL]",
                "details_title" : "Details Screen [INITIAL]",
                "main_show_details_button" : "Show Details [INITIAL]",
                "main_title" : "Main Screen [INITIAL]",
                "menu_explorer_button_title" : "Explorer [INITIAL]",
                "menu_firebase_button_title" : "Firebase [INITIAL]",
                "menu_main_button_title" : "Main [INITIAL]",
                "menu_settings_button_title" : "Settings [INITIAL]",
                "settings_in_bundle" : "In Bundle [INITIAL]",
                "settings_in_sdk" : "In SDK [INITIAL]",
                "test_key" : "Test [INITIAL]",
                "test_parameter" : "Parameter [INITIAL]",
                "test_with_format_key" : "Test parameter - %@ [INITIAL]"
            ],
            "uk": [
                "details_button" : "Кнопка 123 [INITIAL]",
                "details_label" : "Лейбл 12 [INITIAL]",
                "details_segmentedControl_0" : "Значення0 [INITIAL]",
                "details_segmentedControl_1" : "Значення1 [INITIAL]",
                "details_textfield_placeholder" : "Якийсь текст [INITIAL]",
                "details_title" : "Деталі [INITIAL]",
                "main_show_details_button" : "Показати деталі [INITIAL]",
                "main_title" : "Головна [INITIAL]",
                "menu_explorer_button_title" : "Перегляд файлів [INITIAL]",
                "menu_firebase_button_title" : "Firebase [UA] [INITIAL]",
                "menu_main_button_title" : "Головна кнопка [INITIAL]",
                "menu_settings_button_title" : "Налаштування [INITIAL]",
                "settings_in_bundle" : "У бандлі [INITIAL]",
                "settings_in_sdk" : "У СДК [INITIAL]",
                "test_key" : "Тест [INITIAL]",
                "test_parameter" : "Параметр [INITIAL]",
                "test_with_format_key" : "Тестовий параметер - %@ [INITIAL]"
            ]
        ]
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
        
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
            DispatchQueue.main.async {
                self.refresh()
                CrowdinSDK.reloadUI()
            }
        }
    }
    func refresh() {
        localizationDict = self.allLocalization[self.localization] as? [String: String] ?? [:]
    }
    func localizedString(for key: String) -> String? {
        return localizationDict[key]
    }
    
    func keyForString(_ text: String) -> String? {
        let key = localizationDict.first(where: { $1 == text })?.key
        return key
    }
    */
}
