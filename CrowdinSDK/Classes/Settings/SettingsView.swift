//
//  SettingsView.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/4/19.
//

import Foundation

class SettingsView: UIView {
    // swiftlint:disable force_unwrapping
    static let shared: SettingsView? = SettingsView.loadFromNib()
    
    var cells = [SettingsItemCell]()
    
    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.setImage(UIImage(named: "settings-button", in: Bundle.resourceBundle, compatibleWith: nil), for: .normal)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            registerCells()
            setupCells()
        }
    }
    
    fileprivate let closedWidth: CGFloat = 60.0
    fileprivate let openedWidth: CGFloat = 200.0
    fileprivate let defaultItemHeight: CGFloat = 60.0
    let enabledStatusColor = UIColor(red: 60.0 / 255.0, green: 130.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0)
    
    var open: Bool = false {
        didSet {
            setupCells()
            tableView.reloadData()
            if open == true {
                self.frame.size.height = CGFloat(defaultItemHeight + CGFloat(cells.count) * defaultItemHeight)
                self.frame.size.width = openedWidth
            } else {
                self.frame.size.height = defaultItemHeight
                self.frame.size.width = closedWidth
            }
        }
    }
    
    var logsVC: UIViewController? = nil
    
    func dismissLogsVC() {
        logsVC?.cw_dismiss()
        logsVC = nil
    }
    
    class func loadFromNib() -> SettingsView? {
        return UINib(nibName: "SettingsView", bundle: Bundle.resourceBundle).instantiate(withOwner: self, options: nil)[0] as? SettingsView
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
        self.fixPositionIfNeeded()
    }
    
    func fixPositionIfNeeded() {
        let x = validateXCoordinate(value: self.center.x)
        let y = validateYCoordinate(value: self.center.y)
        
        UIView.animate(withDuration: 0.3) {
            self.center = CGPoint(x: x, y: y)
        }
    }
    
    func validateXCoordinate(value: CGFloat) -> CGFloat {
        guard let window = window else { return 0 }
        let minX = self.frame.size.width / 2.0
        let maxX = window.frame.size.width - self.frame.size.width / 2.0
        var x = value
        x = x < minX ? minX : x
        x = x > maxX ? maxX : x
        return x
    }
    
    func validateYCoordinate(value: CGFloat) -> CGFloat {
        guard let window = window else { return 0 }
        let minY = self.frame.size.height / 2.0
        let maxY = window.frame.size.height - self.frame.size.height / 2.0
        var y = value
        y = y < minY ? minY : y
        y = y > maxY ? maxY : y
        return y
    }
}
