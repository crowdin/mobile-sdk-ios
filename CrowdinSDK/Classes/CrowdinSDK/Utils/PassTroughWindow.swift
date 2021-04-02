//
//  PassTroughWindow.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 4/2/21.
//

import Foundation

final class PassTroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
