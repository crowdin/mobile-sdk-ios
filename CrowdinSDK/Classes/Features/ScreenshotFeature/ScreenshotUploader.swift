//
//  ScreenshotUploader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation

public protocol ScreenshotUploader {
	func uploadScreenshot(screenshot: UIImage, controlsInformation: [ControlInformation], name: String, success: (() -> Void)?, errorHandler: ((Error) -> Void)?)
}

class CrowdinScreenshotUploader: ScreenshotUploader {
	var login: String
	var accountKey: String
    var organizationName: String? = nil
	var hash: String
	var strings: [String]
	var plurals: [String]
	var sourceLanguage: String
    
    let distrinbutionsAPI: DistributionsAPI
	
	var mappingManager: CrowdinMappingManagerProtocol
	var projectId: Int? = nil
	
	enum Errors: String {
		case storageIdIsMissing = "Storage id is missing."
		case screenshotIdIsMissing = "Screenshot id is missing."
		case unknownError = "Unknown error"
	}
	
	init(login: String, accountKey: String, organizationName: String? = nil, strings: [String], plurals: [String], hash: String, sourceLanguage: String) {
		self.login = login
		self.accountKey = accountKey
        self.organizationName = organizationName
		self.strings = strings
		self.plurals = plurals
		self.hash = hash
		self.distrinbutionsAPI = DistributionsAPI(hashString: hash, organizationName: organizationName)
		self.sourceLanguage = sourceLanguage
		self.mappingManager = CrowdinMappingManager(strings: strings, plurals: plurals, hash: hash, sourceLanguage: sourceLanguage)
	}
	
	func loginAndGetProjectId(success: (() -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        if LoginFeature.isLogined {
            self.getProjectId(success: success, errorHandler: errorHandler)
        } else if let loginFeature = LoginFeature.shared {
            loginFeature.login(completion: {
                self.getProjectId(success: success, errorHandler: errorHandler)
            }) { err in
                errorHandler?(err)
            }
        } else {
            print("Login feature is not configured properly")
            errorHandler?(NSError(domain: "Login feature is not configured properly", code: defaultCrowdinErrorCode, userInfo: nil))
        }
	}
	
	func getProjectId(success: (() -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
		distrinbutionsAPI.getDistribution { (response, error) in
			if let error = error {
				errorHandler?(error)
			} else if let id = response?.data.project.id, let projectId = Int(id) {
				self.projectId = projectId
				success?()
			} else {
				errorHandler?(NSError(domain: Errors.unknownError.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
			}
		}
	}
	
	func uploadScreenshot(screenshot: UIImage, controlsInformation: [ControlInformation], name: String, success: (() -> Void)?, errorHandler: ((Error) -> Void)?) {
		guard let projectId = self.projectId else {
			self.loginAndGetProjectId(success: {
				DispatchQueue.main.async {
					self.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
				}
			}, errorHandler: errorHandler)
			return
		}
		
		let values = self.proceed(controlsInformation: controlsInformation)
		guard let data = screenshot.pngData() else { return }
		let screenshotsAPI = ScreenshotsAPI(login: login, accountKey: accountKey, organizationName: organizationName)
        let storageAPI = StorageAPI(login: login, accountKey: accountKey, organizationName: organizationName)
		storageAPI.uploadNewFile(data: data, completion: { response, error in
			if let error = error {
				errorHandler?(error)
				return
			}
			guard let storageId = response?.data.id else {
				errorHandler?(NSError(domain: Errors.storageIdIsMissing.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
				return
			}
			screenshotsAPI.createScreenshot(projectId: projectId, storageId: storageId, name: name, completion: { response, error in
				if let error = error {
					errorHandler?(error)
					return
				}
				guard let screenshotId = response?.data.id else {
					errorHandler?(NSError(domain: Errors.screenshotIdIsMissing.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
					return
				}
				guard values.count > 0 else { return }
				screenshotsAPI.createScreenshotTags(projectId: projectId, screenshotId: screenshotId, frames: values, completion: { (_, error) in
					if let error = error {
						errorHandler?(error)
					} else {
						success?()
					}
				})
			})
		})
	}
	
	func proceed(controlsInformation: [ControlInformation]) -> [(id: Int, rect: CGRect)] {
		var results = [(id: Int, rect: CGRect)]()
		controlsInformation.forEach { (controlInformation) in
			if let id = mappingManager.id(for: controlInformation.key) {
				results.append((id: id, rect: controlInformation.rect))
			}
		}
		return results
	}
}
