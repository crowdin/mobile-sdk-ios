//
//  File.swift
//  
//
//  Created by Serhii Londar on 18.06.2022.
//

import Foundation

#if os(OSX)

import AppKit

public typealias View = NSView
public typealias Image = NSImage
public typealias CWScreen = NSScreen

typealias Label = NSTextField
typealias ViewController = NSViewController
typealias Control = NSControl
typealias Window = NSWindow
typealias Application = NSApplication

extension NSView {
    var alpha: CGFloat { alphaValue }
    
    var screenshot: Image? { Image(data: dataWithPDF(inside: bounds)) }
}

extension Image {
    func pngData() -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        bitmap.size = size
        return bitmap.representation(using: .png, properties: [:])
    }
}

extension Label {
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

public typealias View = UIView
public typealias Image = UIImage
public typealias CWScreen = UIScreen

typealias Label = UILabel
typealias ViewController = UIViewController
typealias Window = UIWindow
typealias Application = UIApplication

extension CWScreen {
    public static func scale() -> CGFloat {
        return UIScreen.main.scale
    }
}

#elseif os(watchOS)

import WatchKit

public typealias View = WKInterfaceObject
public typealias Image = WKImage
public typealias CWScreen = WKInterfaceDevice

typealias Label = WKInterfaceLabel
typealias ViewController = WKInterfaceController
typealias Window = WKInterfaceController

extension Label {
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
