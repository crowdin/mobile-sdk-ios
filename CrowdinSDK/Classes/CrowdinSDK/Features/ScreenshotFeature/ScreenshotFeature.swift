//
//  ScreenshotFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/26/19.
//

import UIKit

class ScreenshotFeature {
    static var shared: ScreenshotFeature?
    
    var windows: [UIWindow] { return UIApplication.shared.windows }
    var window: UIWindow? { return UIApplication.shared.keyWindow }
    var mappingManager: CrowdinMappingManagerProtocol
    var projectId: Int
    var login: String
    var accountKey: String
    
    enum Errors: String {
        case storageIdIsMissing = "Storage id is missing."
    }
    
    init(projectId: Int, login: String, accountKey: String, mappingManager: CrowdinMappingManagerProtocol) {
        self.projectId = projectId
        self.login = login
        self.accountKey = accountKey
        self.mappingManager = mappingManager
    }
    
    func captureScreenshot(success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        guard let screenshot = self.window?.screenshot else { return }
        let values = self.captureValues()
        guard let data = screenshot.pngData(), let credentials = "api-tester:VmpFqTyXPq3ebAyNksUxHwhC".data(using: .utf8)?.base64EncodedString() else { return }
        let screenshotsAPI = ScreenshotsAPI(login: "serhii.londar", accountKey: "1267e86b748b600eb851f1c45f8c44ce", credentials: credentials)
        let storageAPI = StorageAPI(login: "serhii.londar", accountKey: "1267e86b748b600eb851f1c45f8c44ce", credentials: credentials)
        storageAPI.uploadNewFile(data: data, completion: { response, error in
            if let error = error {
                errorHandler(error)
                return
            }
            guard let storageId = response?.data.id else {
                errorHandler(NSError(domain: Errors.storageIdIsMissing.rawValue, code: 9999, userInfo: nil))
                return
            }
            let screenshotName = "NewScreenshot\(storageId)" // TODO: find a better way for screnshot naming.
            screenshotsAPI.createScreenshot(projectId: 352187, storageId: storageId, name: screenshotName, completion: { response, error in
                if let error = error {
                    errorHandler(error)
                    return
                }
                guard let screenshotId = response?.data.id else {
                    errorHandler(NSError(domain: "Screenshot id is missing.", code: 9999, userInfo: nil))
                    return
                }
                guard values.count > 0 else { return }
                screenshotsAPI.createScreenshotTags(projectId: 352187, screenshotId: screenshotId, frames: values, completion: { (_, error) in
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
