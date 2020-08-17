//
//  LogsVC.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.08.2020.
//

import Foundation

class CrowdinLogCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setup(with log: CrowdinLog) {
        self.dateLabel.text = CrowdinLogCell.dateFormatter.string(from: log.date)
        self.typeLabel.text = log.type.rawValue
        self.typeLabel.textColor = log.type.color
        self.messageLabel.text = log.message
    }
    static var dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss dd/MM/yyyy"
        return dateFormatter
    }()
}

class CrowdinLogsVC: UITableViewController {
    override var tableView: UITableView! {
        didSet {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl!)
            }
        }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CrowdinLogsCollector.shared.logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CrowdinLogCell", for: indexPath) as? CrowdinLogCell else { return UITableViewCell() }
        cell.setup(with: CrowdinLogsCollector.shared.logs[indexPath.row])
        return cell
    }
}
