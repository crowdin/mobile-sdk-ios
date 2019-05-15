//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

struct ScreenshotFeatureConfig {
    var projectId: Int
    var login: String
    var credentials: String
    var accountKey: String
    var strings: [String]
    var plurals: [String]
    var hash: String
    var sourceLanguage: String
}

class ScreenshotFeature {
    static var shared: ScreenshotFeature?
    
    var mappingManager: CrowdinMappingManagerProtocol
    var config: ScreenshotFeatureConfig
    
    enum Errors: String {
        case storageIdIsMissing = "Storage id is missing."
    }
    
    init(config: ScreenshotFeatureConfig) {
        self.config = config
        self.mappingManager = CrowdinMappingManager(strings: config.strings, plurals: config.plurals, hash: config.hash, sourceLanguage: config.sourceLanguage)
    }
    
    func captureScreenshot(name: String, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshot = self.window?.screenshot else { return }
        let values = self.captureValues()
        guard let data = screenshot.pngData() else { return }
        let screenshotsAPI = ScreenshotsAPI(login: config.login, accountKey: config.accountKey, credentials: config.credentials)
        let storageAPI = StorageAPI(login: config.login, accountKey: config.accountKey, credentials: config.credentials)
        storageAPI.uploadNewFile(data: data, completion: { response, error in
            if let error = error {
                errorHandler(error)
                return
            }
            guard let storageId = response?.data.id else {
                errorHandler(NSError(domain: Errors.storageIdIsMissing.rawValue, code: 9999, userInfo: nil))
                return
            }
            screenshotsAPI.createScreenshot(projectId: self.config.projectId, storageId: storageId, name: name, completion: { response, error in
                if let error = error {
                    errorHandler(error)
                    return
                }
                guard let screenshotId = response?.data.id else {
                    errorHandler(NSError(domain: "Screenshot id is missing.", code: 9999, userInfo: nil))
                    return
                }
                guard values.count > 0 else { return }
                screenshotsAPI.createScreenshotTags(projectId: self.config.projectId, screenshotId: screenshotId, frames: values, completion: { (_, error) in
                    if let error = error {
                        errorHandler(error)
                    } else {
                        success()
                    }
                })
            })
        })
    }
}

extension ScreenshotFeature {
    fileprivate func captureValues() -> [Int: CGRect] {
        guard let window = self.window else { return [Int: CGRect]() }
        let values = self.getValues(from: window)
        let koef = window.screen.scale
        var returnValue = [Int: CGRect]()
        values.forEach { (key: Int, value: CGRect) in
            returnValue[key] = CGRect(x: value.origin.x * koef, y: value.origin.y * koef, width: value.size.width * koef, height: value.size.height * koef)
        }
        return returnValue
    }
    
    fileprivate func getValues(from view: UIView) -> [Int: CGRect] {
        var description = [Int: CGRect]()
        view.subviews.forEach { (view) in
            if let label = view as? UILabel, let localizationKey = label.localizationKey, let id = mappingManager.id(for: localizationKey) {
                if let frame = label.superview?.convert(label.frame, to: window) {
                    description[id] = frame
                }
            }
            description.merge(with: getValues(from: view))
        }
        return description
    }
}

extension ScreenshotFeature {
    var windows: [UIWindow] { return UIApplication.shared.windows }
    var window: UIWindow? { return UIApplication.shared.keyWindow }
}
