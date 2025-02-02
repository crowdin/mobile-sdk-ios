//
//  LogsVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.08.2020.
//

#if os(iOS) || os(tvOS)

import UIKit

final class CrowdinLogsVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name.refreshLogsName, object: nil)

        tableView.register(CrowdinLogCell.self, forCellReuseIdentifier: "CrowdinLogCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }

    // swiftlint:disable implicitly_unwrapped_optional
    override var tableView: UITableView! {
        didSet {
#if os(iOS)
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                // swiftlint:disable force_unwrapping
                tableView.addSubview(refreshControl!)
            }
#endif
        }
    }

    @objc func reloadData() {
        tableView.reloadData()
#if os(iOS)
        refreshControl?.endRefreshing()
#endif
    }

    // MARK: - Private

    private func didSelect(_ indexPath: IndexPath) {
        let cellViewModel = CrowdinLogCellViewModel(log: CrowdinLogsCollector.shared.logs[indexPath.row])

        guard cellViewModel.isShowArrow else {
            return
        }

        openLogsDetails(cellViewModel: cellViewModel)
    }

    private func openLogsDetails(cellViewModel: CrowdinLogCellViewModel) {
        let logDetailsVC = CrowdinLogDetailsVC(details: cellViewModel.attributedText)
        navigationController?.pushViewController(logDetailsVC, animated: true)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CrowdinLogsCollector.shared.logs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CrowdinLogCell", for: indexPath) as? CrowdinLogCell else { return UITableViewCell() }
        let cellViewModel = CrowdinLogCellViewModel(log: CrowdinLogsCollector.shared.logs[indexPath.row])
        cell.setup(with: cellViewModel)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath)
    }
}

#endif
