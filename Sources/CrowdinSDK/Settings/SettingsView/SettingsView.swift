//
//  SettingsView.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 4/4/19.
//

#if os(iOS) || os(tvOS)

import UIKit

final class SettingsView: UIView {
    static var shared: SettingsView? = SettingsView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))

    var settingsWindow = SettingsWindow() {
        didSet {
            settingsWindow.settingsView = self
        }
    }

    var cells = [SettingsItemView]()

    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    var settingsButton = UIButton()
    var closeButton = UIButton()
    var stackView = UIStackView()

    fileprivate let closedWidth: CGFloat = 60.0
    fileprivate let openedWidth: CGFloat = 200.0
    fileprivate let defaultItemHeight: CGFloat = 60.0
    let enabledStatusColor = UIColor(red: 60.0 / 255.0, green: 130.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setupUI() {
        addViews()
        layoutViews()
        setupViews()
    }

    func addViews() {
        translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        addSubview(settingsButton)
        addSubview(closeButton)
        addSubview(stackView)
    }

    func layoutViews() {
        addConstraints([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),

            settingsButton.topAnchor.constraint(equalTo: topAnchor),
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),

            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),

            stackView.topAnchor.constraint(equalTo: settingsButton.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        translatesAutoresizingMaskIntoConstraints = true
    }

    func setupViews() {
        settingsButton.setImage(UIImage(named: "settings-button", in: Bundle.module, compatibleWith: nil), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)

        closeButton.setImage(UIImage(named: "close_icon", in: Bundle.module, compatibleWith: nil), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.isHidden = true

        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        clipsToBounds = true

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        self.addGestureRecognizer(gesture)
        self.isUserInteractionEnabled = true
        gesture.delegate = self
    }

    var open: Bool = false {
        didSet {
            reloadData()
            self.blurView.isHidden = open
            self.backgroundColor = open ? UIColor(red: 45.0 / 255.0, green: 49.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0) : .clear
            reloadUI()
            closeButton.isHidden = !open
        }
    }

    func reloadData() {
        setupCells()
        stackView.arrangedSubviews.forEach({ stackView.removeArrangedSubview($0) })
        cells.forEach({ stackView.addArrangedSubview($0) })
    }

    var logsVC: UIViewController? = nil

    func dismissLogsVC() {
        logsVC?.cw_dismiss()
        logsVC = nil
    }

    func reloadUI() {
        if open == true {
            self.frame.size.height = CGFloat(defaultItemHeight + CGFloat(cells.count) * defaultItemHeight)
            self.frame.size.width = openedWidth
        } else {
            self.frame.size.height = defaultItemHeight
            self.frame.size.width = closedWidth
        }
    }

    // MARK: - IBActions

    @objc
    func settingsButtonPressed() {
        self.open = !self.open
        self.fixPositionIfNeeded()
    }

    @objc
    func closeButtonPressed() {
        open = false
    }

    // MARK: - Private
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

    func logout() {
        if let realtimeUpdateFeature = RealtimeUpdateFeature.shared, realtimeUpdateFeature.enabled {
            realtimeUpdateFeature.stop()
        }
        CrowdinSDK.loginFeature?.logout()
        reloadData()

        CrowdinLogsCollector.shared.add(log: .info(with: "Logged out"))
    }
}

#endif
