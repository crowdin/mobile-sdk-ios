//
//  File.swift
//  
//
//  Created by Serhii Londar on 18.06.2022.
//

import Foundation

#if os(OSX)
    import AppKit
    
    typealias Label = NSTextField
    public typealias View = NSView
    typealias ViewController = NSViewController
    public typealias Image = NSImage
    typealias Control = NSControl

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

#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit

    typealias Label = UILabel
    public typealias View = UIView
    typealias ViewController = UIViewController
    public typealias Image = UIImage
    typealias Control = UIControl

#endif
