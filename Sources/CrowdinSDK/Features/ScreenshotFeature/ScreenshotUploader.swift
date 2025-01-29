//
//  ScreenshotUploader.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 7/18/19.
//

import Foundation
import CoreGraphics

#if !os(watchOS)

public protocol ScreenshotUploader {
	func uploadScreenshot(screenshot: CWImage, controlsInformation: [ControlInformation], name: String, success: (() -> Void)?, errorHandler: ((Error) -> Void)?)
    func updateOrUploadScreenshot(screenshot: CWImage, controlsInformation: [ControlInformation], name: String, success: ((ScreenshotUploadResult) -> Void)?, errorHandler: ((Error) -> Void)?)

    func prepare(completion: @escaping (Error?) -> Void)
    func prepareSync() -> Error?
}

public enum ScreenshotUploadResult {
    case new
    case udpated
}

class CrowdinScreenshotUploader: ScreenshotUploader {
    var organizationName: String?
	var hash: String
	var sourceLanguage: String

    let loginFeature: AnyLoginFeature?
    let storageAPI: StorageAPI

	var mappingManager: CrowdinMappingManager
	var projectId: Int? = nil

	enum Errors: String {
		case storageIdIsMissing = "Storage id is missing."
		case screenshotIdIsMissing = "Screenshot id is missing."
		case unknownError = "Unknown error."
        case noLocalizedStringsDetected = "There are no localized strings detected on current screen."
	}

    init(organizationName: String?, hash: String, sourceLanguage: String, loginFeature: AnyLoginFeature?) {
        self.organizationName = organizationName
		self.hash = hash
		self.sourceLanguage = sourceLanguage
        self.mappingManager = CrowdinMappingManager(hash: hash, sourceLanguage: sourceLanguage, organizationName: organizationName)
        self.loginFeature = loginFeature
        self.storageAPI = StorageAPI(organizationName: organizationName, auth: loginFeature)
	}

	func loginAndGetProjectId(success: (() -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        if let loginFeature {
            if loginFeature.isLogined {
                self.getProjectId(success: success, errorHandler: errorHandler)
            } else {
                loginFeature.login(completion: {
                    self.getProjectId(success: success, errorHandler: errorHandler)
                }) { err in
                    errorHandler?(err)
                }
            }
        } else {
            errorHandler?(NSError(domain: "Login feature is not configured properly", code: defaultCrowdinErrorCode, userInfo: nil))
        }
	}

	func getProjectId(success: (() -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        let distributionsAPI = DistributionsAPI(hashString: hash, organizationName: organizationName, auth: loginFeature)
		distributionsAPI.getDistribution { (response, error) in
			if let error = error {
				errorHandler?(error)
			} else if let id = response?.data.project.id, let projectId = Int(id) {
				self.projectId = projectId
                CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Get distribution success"))
				success?()
			} else {
				errorHandler?(NSError(domain: Errors.unknownError.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
                CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .info, message: "Get distribution failed - \(Errors.unknownError.rawValue)"))
			}
		}
	}

    func prepare(completion: @escaping (Error?) -> Void) {
        downloadMappingIfNeeded(completion: { error in
            DispatchQueue.main.async {
                completion(error)
            }
        })
    }

    func prepareSync() -> Error? {
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error? = nil
        downloadMappingIfNeeded {
            error = $0
            semaphore.signal()
        }
        semaphore.wait()
        return error
    }

    func downloadMappingIfNeeded(completion: @escaping (Error?) -> Void) {
        if mappingManager.downloaded {
            completion(nil)
        } else {
            mappingManager.downloadCompletions.append({ errors in
                if let errors, let error = self.combineErrors(errors) {
                    completion(error)
                    return
                }
                completion(nil)
            })
        }
    }

	func uploadScreenshot(screenshot: CWImage, controlsInformation: [ControlInformation], name: String, success: (() -> Void)?, errorHandler: ((Error) -> Void)?) {
		guard let projectId = self.projectId else {
			self.loginAndGetProjectId(success: {
                self.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
			}, errorHandler: errorHandler)
			return
		}

		guard let data = screenshot.pngData() else { return }
        let screenshotsAPI = ScreenshotsAPI(organizationName: organizationName, auth: loginFeature)

        storageAPI.uploadNewFile(data: data, fileName: name, completion: { response, error in
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
                let screenRect = CGRect(origin: .zero, size: screenshot.size.applying(CGAffineTransformScale(.identity, screenshot.scale, screenshot.scale)))
                let values = self.proceed(controlsInformation: controlsInformation, screenRect: screenRect)
                guard values.count > 0 else {
                    CrowdinLogsCollector.shared.add(log: .warning(with: "Screenshot uploaded without tags"))
                    success?()
                    return
                }
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

    func updateOrUploadScreenshot(screenshot: CWImage, controlsInformation: [ControlInformation], name: String, success: ((ScreenshotUploadResult) -> Void)?, errorHandler: ((Error) -> Void)?) {
        guard let projectId = self.projectId else {
            self.loginAndGetProjectId(success: {
                self.updateOrUploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: success, errorHandler: errorHandler)
            }, errorHandler: errorHandler)
            return
        }

        let screenshotsAPI = ScreenshotsAPI(organizationName: organizationName, auth: loginFeature)

        screenshotsAPI.listScreenshots(projectId: projectId, query: name) { response, error in
            guard let response else {
                errorHandler?(error ?? NSError(domain: Errors.unknownError.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
                return
            }
            if response.data.count > 0 {
                if response.data.count > 1 {
                    CrowdinLogsCollector.shared.add(log: CrowdinLog(type: .warning, message: "Encountered multiple screenshots with the same name - \(name); only one will be updated."))
                }
                let screnshotId = response.data[0].data.id
                let storageAPI = StorageAPI(organizationName: self.organizationName, auth: self.loginFeature)

                guard let data = screenshot.pngData() else { return }

                storageAPI.uploadNewFile(data: data, fileName: name, completion: { response, error in
                    if let error = error {
                        errorHandler?(error)
                        return
                    }
                    guard let storageId = response?.data.id else {
                        errorHandler?(NSError(domain: Errors.storageIdIsMissing.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
                        return
                    }

                    screenshotsAPI.updateScreenshot(projectId: projectId, screnshotId: screnshotId, storageId: storageId, name: name) { response, error in
                        if let error = error {
                            errorHandler?(error)
                            return
                        }
                        guard let screenshotId = response?.data.id else {
                            errorHandler?(NSError(domain: Errors.screenshotIdIsMissing.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
                            return
                        }
                        let screenRect = CGRect(origin: .zero, size: screenshot.size.applying(CGAffineTransformScale(.identity, screenshot.scale, screenshot.scale)))
                        let values = self.proceed(controlsInformation: controlsInformation, screenRect: screenRect)
                        guard values.count > 0 else {
                            CrowdinLogsCollector.shared.add(log: .warning(with: "Screenshot uploaded without tags"))
                            success?(.udpated)
                            return
                        }

                        screenshotsAPI.createScreenshotTags(projectId: projectId, screenshotId: screenshotId, frames: values, completion: { (_, error) in
                            if let error = error {
                                errorHandler?(error)
                            } else {
                                success?(.udpated)
                            }
                        })
                    }
                })
            } else {
                self.uploadScreenshot(screenshot: screenshot, controlsInformation: controlsInformation, name: name, success: {
                    success?(.new)
                }, errorHandler: errorHandler)
            }

        }
    }

    func proceed(controlsInformation: [ControlInformation], screenRect: CGRect) -> [(id: Int, rect: CGRect)] {
		var results = [(id: Int, rect: CGRect)]()
        var controlsWithId = [(id: Int, rect: CGRect)]()
		controlsInformation.forEach { (controlInformation) in
			if let id = mappingManager.id(for: controlInformation.key) {
                controlsWithId.append((id: id, rect: controlInformation.rect))
			}
		}

        controlsWithId.forEach({
            if screenRect.contains($0.rect)  {
                results.append($0)
            } else {
                let visibleRect = screenRect.intersection($0.rect)
                if visibleRect.isValid {
                    results.append(($0.id, visibleRect))
                }
            }
        })

		return results
	}

    func combineErrors(_ errors: [Error]) -> Error? {
        // If no errors, return nil
        guard !errors.isEmpty else { return nil }

        // If only one error, return that error
        guard errors.count > 1 else { return errors.first }

        // Custom error type to combine multiple errors
        struct MultipleErrors: Error {
            let errors: [Error]

            var localizedDescription: String {
                return errors.map { $0.localizedDescription }.joined(separator: "; ")
            }
        }

        return MultipleErrors(errors: errors)
    }
}

extension CGRect {
    func contains(rect: CGRect) -> Bool {
        return self.contains(rect.origin) &&
               self.contains(CGPoint(x: rect.maxX, y: rect.maxY)) &&
               self.contains(CGPoint(x: rect.maxX, y: rect.minY)) &&
               self.contains(CGPoint(x: rect.minX, y: rect.maxY))
    }
}

#endif
