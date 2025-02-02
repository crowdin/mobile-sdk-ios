//
//  File.swift
//
//
//  Created by Serhii Londar on 18.06.2022.
//

import Foundation

#if os(OSX)

import AppKit

public typealias CWView = NSView
public typealias CWImage = NSImage
public typealias CWScreen = NSScreen

typealias CWLabel = NSTextField
typealias CWViewController = NSViewController
typealias CWControl = NSControl
typealias CWWindow = NSWindow
typealias CWApplication = NSApplication

extension CWView {
    var alpha: CGFloat { alphaValue }

    var screenshot: CWImage? { CWImage(data: dataWithPDF(inside: bounds)) }
}

extension CWImage {
    func pngData() -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        bitmap.size = size
        return bitmap.representation(using: .png, properties: [:])
    }

    var scale: Double {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return 1 }
        return Double(cgImage.width) / Double(size.width)
    }
}

extension CWLabel {
    var text: String {
        get {
            stringValue
        }
        set {
            stringValue = newValue
        }
    }
}

extension CWScreen {
    public static func scale() -> CGFloat {
        return NSScreen.main?.backingScaleFactor ?? 1
    }
}

#elseif os(iOS) || os(tvOS)

import UIKit

public typealias CWView = UIView
public typealias CWImage = UIImage
public typealias CWScreen = UIScreen

typealias CWLabel = UILabel
typealias CWViewController = UIViewController
typealias CWWindow = UIWindow
typealias CWApplication = UIApplication

extension CWScreen {
    public static func scale() -> CGFloat {
        return UIScreen.main.scale
    }
}

#elseif os(watchOS)

import WatchKit

public typealias CWView = WKInterfaceObject
public typealias CWImage = WKImage
public typealias CWScreen = WKInterfaceDevice

typealias CWLabel = WKInterfaceLabel
typealias CWViewController = WKInterfaceController
typealias CWWindow = WKInterfaceController

extension CWLabel {
    var text: String? {
        set {
            setText(newValue)
        }
        get {
            nil
        }
    }
}

extension CWScreen {
    public static func scale() -> CGFloat {
        return WKInterfaceDevice.current().screenScale
    }
}

#endif
