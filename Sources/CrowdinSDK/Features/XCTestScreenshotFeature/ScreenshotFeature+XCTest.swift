//
//  ScreenshotFeature+XCTest.swift
//  Pods
//
//  Created by Serhii Londar on 27.11.2024.
//
import XCTest
import UIKit
import CrowdinSDK

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

extension XCUIApplication {
    func getAllControlsWithText() -> [XCUIElement] {
        var controls = [XCUIElement]()
        for element in descendants(matching: .any) {
            if !element.label.isEmpty {
                controls.append(element)
            }
        }
        return controls
    }
    
    func getControlsInformation() -> [ControlInformation] {
        var controls = [ControlInformation]()
        for control in getAllControlsWithText() {
            print(control.label)
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
        return rect.apply(scale: UIScreen.main.scale)
    }
}

extension CGRect {
    func apply(scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale, width: width * scale, height: height * scale)
    }
}


extension CrowdinSDK {
    public class func captureScreenshot(name: String, image: UIImage, application: XCUIApplication, success: @escaping (() -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        CrowdinSDK.captureScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: success, errorHandler: errorHandler)
    }
    
    
    public class func captureScreenshotSync(name: String, image: UIImage, application: XCUIApplication) -> Error? {
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        CrowdinSDK.captureScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: { }, errorHandler: {
            error = $0
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return error
    }
    
    public class func captureOrUpdateScreenshot(name: String, image: UIImage, application: XCUIApplication, success: @escaping ((ScreenshotUploadResult) -> Void), errorHandler: @escaping ((Error?) -> Void)) {
        CrowdinSDK.captureOrUpdateScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: success, errorHandler: errorHandler)
    }
    
    public class func captureOrUpdateScreenshotSync(name: String, image: UIImage, application: XCUIApplication) -> (ScreenshotUploadResult?, Error?) {
        var result: ScreenshotUploadResult?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        CrowdinSDK.captureOrUpdateScreenshot(name: name, screenshot: image, controlsInformation: application.getControlsInformation(), success: {
            result = $0
            semaphore.signal()
        }, errorHandler: {
            error = $0
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: .distantFuture)
        return (result, error)
    }
    
    public class func startWithConfigSync(_ config: CrowdinSDKConfig) {
        let semaphore = DispatchSemaphore(value: 1)
        startWithConfig(config) {
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
}
