//
//  LocalizationUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/10/19.
//

import Foundation

class LocalizationUpdateFeature {
    static var shared: LocalizationUpdateFeature?
    
    private var controls = NSHashTable<AnyObject>.weakObjects()
    
    func subscribe(control: Updatable) {
        controls.add(control)
        control.subscribe()
    }
}

protocol Updatable: NSObjectProtocol {
    func subscribe()
    func unsubscribe()
    func update(_ text: String)
}

extension UILabel: Updatable {
    private static let editButtonAssociation = ObjectAssociation<UIButton>()
    
    var editButton: UIButton? {
        get { return UILabel.editButtonAssociation[self] }
        set { UILabel.editButtonAssociation[self] = newValue }
    }
    
    func subscribe() {
        guard editButton == nil else { return }
        self.isUserInteractionEnabled = true
        let button = UIButton(type: UIButton.ButtonType.infoLight)
        button.addTarget(self, action: #selector(editButtonHandler(_:)), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: self.frame.width - 40, y: 0, width: 40, height: 40)
        self.addSubview(button)
        self.editButton = button
    }
    
    func unsubscribe() {
        guard let editButton = self.editButton else { return }
        editButton.removeFromSuperview()
        self.editButton = nil
    }
    
    @objc func editButtonHandler(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LocalizationUpdateVC", bundle: Bundle(for: LocalizationUpdateVC.self))
        guard let localizationUpdateVC = storyboard.instantiateViewController(withIdentifier: "LocalizationUpdateVC") as? LocalizationUpdateVC else { return }
        localizationUpdateVC.control = self
        UIApplication.shared.keyWindow?.rootViewController?.present(localizationUpdateVC, animated: true, completion: nil)
    }
    
    func update(_ text: String) {
        self.text = text
    }
}
