//
//  TeamListViewController.swift
//  NEKitContactUI
//
//  Created by yuanyuan on 2022/1/13.
//

import UIKit

class TeamListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView(frame: .zero, style: .plain)
    var viewModel = TeamListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonUI()
        loadData()
    }
    
    func commonUI() {
        self.title = "我的群聊"
        let image = UIImage.ne_imageNamed(name: "backArrow")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backEvent))
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        self.tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: "\(NSStringFromClass(TeamTableViewCell.self))")
        self.tableView.rowHeight = 62
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    
    func loadData() {
        viewModel.getTeamList()
        self.tableView.reloadData()
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teamList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(TeamTableViewCell.self))", for: indexPath) as! TeamTableViewCell
        cell.setModel(viewModel.teamList[indexPath.row])
        return cell
    }
    
    @objc func backEvent() {
        self.navigationController?.popViewController(animated: true)
    }

}
