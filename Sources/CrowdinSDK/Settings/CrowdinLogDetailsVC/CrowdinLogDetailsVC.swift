//
//  CrowdinLogDetailsVC.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 2/16/21.
//

#if os(iOS) || os(tvOS)

import UIKit

final class CrowdinLogDetailsVC: UIViewController {
    private var textView = UITextView()
    private var details: NSAttributedString?

    // MARK: - Lifecycle

    init(details: NSAttributedString?) {
        super.init(nibName: nil, bundle: nil)
        self.details = details
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        addViews()
        layoutViews()
        setupViews()
    }

    private func addViews() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
    }

    private func layoutViews() {
        view.addConstraints([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func setupViews() {
        textView.attributedText = details
    }
}
#endif
