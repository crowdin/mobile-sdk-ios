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
    
    init(strings: [String], plurals: [String], sourceLanguage: String, hash: String) {
        self.mappingManager = CrowdinMappingManager(strings: strings, plurals: plurals, hash: hash, sourceLanguage: sourceLanguage)
    }
    
    func captureScreenshot(completion: @escaping ((Bool) -> Void), error: @escaping ((Error) -> Void)) {
    
    }
    
    func captureScreenshot() {
        guard let screenshot = self.screenshot else { return }
        let storyboard = UIStoryboard(name: "SaveScreenshotVC", bundle: Bundle(for: SaveScreenshotVC.self))
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SaveScreenshotVC") as? SaveScreenshotVC else { return }
        vc.screenshot = screenshot
        vc.values = captureValues()
        vc.delegate = self
        // TODO: Add screenshot VC as subview to avoid issues with already presented VC.
        ScreenshotFeature.shared?.window?.rootViewController?.present(vc, animated: true, completion: { })
    }
    
    var screenshot: UIImage? {
        guard let window = self.window else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.frame.size, true, window.screen.scale)
        defer { UIGraphicsEndImageContext() }
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func captureValues() -> [Int: CGRect] {
        guard let window = self.window else { return [Int: CGRect]() }
        let values = self.getValues(from: window)
        let koef = window.screen.scale
        var returnValue = [Int: CGRect]()
        values.forEach { (key: Int, value: CGRect) in
            returnValue[key] = CGRect(x: value.origin.x * koef, y: value.origin.y * koef, width: value.size.width * koef, height: value.size.height * koef)
        }
        return returnValue
    }
    
    func getValues(from view: UIView) -> [Int: CGRect] {
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

extension ScreenshotFeature: SaveScreenshotVCDelegate {
    func saveButtonPressed(_ sender: SaveScreenshotVC) {
        let values = self.captureValues()
        if let screenshot = sender.screenshot, let data = screenshot.pngData(), let credentials = "api-tester:VmpFqTyXPq3ebAyNksUxHwhC".data(using: .utf8)?.base64EncodedString() {
            let screenshotsAPI = ScreenshotsAPI(login: "serhii.londar", accountKey: "1267e86b748b600eb851f1c45f8c44ce", credentials: credentials)
            let storageAPI = StorageAPI(login: "serhii.londar", accountKey: "1267e86b748b600eb851f1c45f8c44ce", credentials: credentials)
            storageAPI.uploadNewFile(data: data, completion: { response, error in
                guard let storageId = response?.data.id else { return }
                screenshotsAPI.createScreenshot(projectId: 352187, storageId: storageId, name: "NewScreenshot\(storageId)", completion: { response, error in
                    guard let screenshotId = response?.data.id else { return }
                    guard values.count > 0 else { return }
                    screenshotsAPI.createScreenshotTags(projectId: 352187, screenshotId: screenshotId, frames: values, completion: { (response, error) in
                        
                    })
                })
            })
        }
    }
}
