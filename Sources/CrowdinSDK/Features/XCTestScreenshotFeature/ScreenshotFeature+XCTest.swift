//
//  ScreenshotFeature+XCTest.swift
//  Pods
//
//  Created by Serhii Londar on 27.11.2024.
//
import XCTest

#if CrowdinSDKSPM
import CrowdinSDK
#endif

#if !os(watchOS) && !os(tvOS)

#if compiler(>=6.0)
extension XCUIElementQuery: @retroactive Sequence {
    public typealias Iterator = AnyIterator<XCUIElement>
    public func makeIterator() -> Iterator {
        var index = UInt(0)
        return AnyIterator {
            guard index < self.count else { return nil }

            let element = self.element(boundBy: Int(index))
            index = index + 1
            return element
        }
    }
}
#else
extension XCUIElementQuery: Sequence {
    public typealias Iterator = AnyIterator<XCUIElement>
    public func makeIterator() -> Iterator {
        var index = UInt(0)
        return AnyIterator {
            guard index < self.count else { return nil }

            let element = self.element(boundBy: Int(index))
            index = index + 1
            return element
        }
    }
}
#endif

extension XCUIApplication {
    func getAllControlsWithText() -> [XCUIElement] {
        var controls = [XCUIElement]()
        for element in descendants(matching: .staticText) {
            if !element.label.isEmpty {
                controls.append(element)
            }
        }
        return controls
    }

    func getControlsInformation() -> [ControlInformation] {
        var controls = [ControlInformation]()
        for control in getAllControlsWithText() {
            if let key = CrowdinSDK.keyFor(string: control.label) {
                controls.append(ControlInformation(key: key, rect: control.rect))
            }
        }
        return controls
    }
}

extension XCUIElement {
    var rect: CGRect {
        let frame = frame
        let point = coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let start = point.screenPoint

        let end = CGPoint(x: start.x + frame.width, y: start.y + frame.height)
        let rect = CGRect(origin: start, size: CGSize(width: end.x - start.x, height: end.y - start.y))
        return rect.apply(scale: CWScreen.scale())
    }
}

extension CGRect {
    func apply(scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale, width: width * scale, height: height * scale)
    }
}

extension CrowdinSDK {
    public class func captureScreenshot(name: String, image: CWImage, application: XCUIApplication, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        CrowdinSDK.captureScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: success, errorHandler: errorHandler)
    }

    public class func captureScreenshotSync(name: String, image: CWImage, application: XCUIApplication) -> Error? {
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        CrowdinSDK.captureScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: {
            semaphore.signal()
        }, errorHandler: {
            error = $0
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return error
    }

    public class func captureOrUpdateScreenshot(
        name: String,
        image: CWImage,
        application: XCUIApplication,
        success: @escaping ((ScreenshotUploadResult) -> Void),
        errorHandler: @escaping ((Error?) -> Void)
    ) {
        CrowdinSDK.captureOrUpdateScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: success, errorHandler: errorHandler)
    }

    public class func captureOrUpdateScreenshotSync(name: String, image: CWImage, application: XCUIApplication) -> (result: ScreenshotUploadResult?, error: Error?) {
        var result: ScreenshotUploadResult?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let controlsInformation = application.getControlsInformation()
        DispatchQueue.global().async {
            CrowdinSDK.captureOrUpdateScreenshot(name: name, screenshot: image, controlsInformation: controlsInformation, success: {
                result = $0
                semaphore.signal()
            }, errorHandler: {
                error = $0
                semaphore.signal()
            })
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return (result, error)
    }

    /// Method to start sdk synchroniously.
    /// - Warning: Method is used for UI tests, not recommended to use in production.
    /// - Parameter config: Crowdin SDK config.
    public class func startWithConfigSync(_ config: CrowdinSDKConfig) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            startWithConfig(config) {
                semaphore.signal()
            }
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
}

#endif
