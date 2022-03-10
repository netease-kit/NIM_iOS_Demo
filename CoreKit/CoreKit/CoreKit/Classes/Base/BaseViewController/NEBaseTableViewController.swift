//
//  NEBaseTableViewController.swift
//  QChatKit-ui
//
//  Created by yuanyuan on 2022/1/21.
//

import UIKit
import CoreGraphics

open class NEBaseTableViewController: NEBaseViewController {
    
    
    open lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.sectionFooterHeight = 0
        table.sectionHeaderHeight = 0
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0.0
        }
        if #available(iOS 11.0, *){
            table.contentInsetAdjustmentBehavior = .always
        }
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        header.backgroundColor = .clear
        table.tableHeaderView = header
        return table
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    open func setupTable(){
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
