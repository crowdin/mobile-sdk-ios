//
//  SaveScreenshotVC.swift
//  CrowdinSDK_Example
//
//  Created by Serhii Londar on 1/27/19.
//  Copyright © 2019 Crowdin. All rights reserved.
//

import UIKit

class SaveScreenshotVC: UIViewController {
    let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
    var screenshot: UIImage!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = screenshot
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var screenshotNameTextField: UITextField! {
        didSet {
            screenshotNameTextField.placeholder = "Please enter acreenshot name"
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss"
            let name = dateFormatter.string(from: Date())
            screenshotNameTextField.text = name
        }
    }

    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        self.createScreenshotsFolderIfNeeded()
        let screenshotsFolder = Folder(path: crowdinFolder.path + "/" + "Screenshots")
        let screenshotFileName = (self.screenshotNameTextField.text ?? DateFormatter().string(from: Date())) + ".png"
        let screenshotFile = ImageFile(path: screenshotsFolder.path + "/" + screenshotFileName)
        screenshotFile.image = screenshot
        try? screenshotFile.save()
        self.dismiss(self)
    }
    
    func createScreenshotsFolderIfNeeded() {
        let screenshotsFolder = Folder(path: crowdinFolder.path + "/" + "Screenshots")
        if !screenshotsFolder.isCreated {
            try? screenshotsFolder.create()
        }
    }
}
