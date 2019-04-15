//
//  SettingsView.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/4/19.
//

import Foundation

class SettingsView: UIView {
    // swiftlint:disable force_unwrapping
    static let shared: SettingsView = SettingsView.loadFromNib()!
    
    var cells = [SettingsItemCell]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            registerCells()
            setupCells()
        }
    }
    var open: Bool = false {
        didSet {
            if open == true {
                self.frame.size.height = CGFloat(60 + cells.count * 60);
            } else {
                self.frame.size.height = 60;
            }
        }
    }
    
    class func loadFromNib() -> SettingsView? {
        return UINib(nibName: "SettingsView", bundle: Bundle(for: SettingsView.self)).instantiate(withOwner: nil, options: nil)[0] as? SettingsView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        self.addGestureRecognizer(gesture)
        self.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        self.addGestureRecognizer(gesture)
        self.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    @IBAction func settingsButtonPressed() {
        self.open = !self.open
    }
    
    func fixPositionIfNeeded() {
        guard let window = window else { return }
        let minX: CGFloat = 0
        let maxX = window.frame.size.width - self.frame.size.width
        let currentX = self.frame.origin.x
        var x: CGFloat = 0
        x = currentX < minX ? minX : currentX
        x = x > maxX ? maxX : x
        
        let minY: CGFloat = 0
        let maxY = window.frame.size.height - self.frame.size.height
        let currentY = self.frame.origin.y
        var y: CGFloat = 0
        y = currentY < minY ? minY : currentY
        y = y > maxY ? maxY : y
        
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(origin: CGPoint(x: x, y: y), size: self.frame.size)
        }
    }
}
