//
//  ValidationMessageViewController.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/14.
//

import UIKit
import NEKitCore
public class ValiationMessageConfig {
    
}

class ValidationMessageViewController: ContactBaseViewController {

    let viewModel = ValidationMessageViewModel()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = localizable("验证消息")
        //viewModel.getValidationMessage()
        setupUI()
        weak var weakSelf = self
        viewModel.getValidationMessage {
            weakSelf?.tableView.reloadData()
        }
        
        viewModel.dataRefresh = {
            weakSelf?.tableView.reloadData()
        }
    }
    
    func setupUI(){
        let clearItem = UIBarButtonItem(title: "清空", style: .done, target: self, action: #selector(clearMessage))
        clearItem.tintColor = UIColor(hexString: "666666")
        navigationItem.rightBarButtonItem = clearItem
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(BaseValidationCell.self, forCellReuseIdentifier: "\(BaseValidationCell.self)")
                                            
    }
    
    @objc func clearMessage(){
        weak var weakSelf = self
        showAlert(message: "是否要清除所有验证消息？") {
            weakSelf?.viewModel.clearAllNoti {
                weakSelf?.tableView.reloadData()
            }
        }
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

extension ValidationMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BaseValidationCell = tableView.dequeueReusableCell(withIdentifier: "\(BaseValidationCell.self)", for: indexPath) as! BaseValidationCell
        let noti = viewModel.datas[indexPath.row]
        cell.confige(noti)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
}
