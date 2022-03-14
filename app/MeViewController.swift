//
//  MeViewController.swift
//  app
//
//  Created by yuanyuan on 2022/2/16.
//

import UIKit
import YXLogin
import NEKitCore
import NIMSDK
import NEKitCoreIM
import NEKitQChatUI
import YXLogin

class MeViewController: UIViewController {

    lazy var header: QChatUserHeaderView = {
        let view = QChatUserHeaderView(frame: .zero)
        view.titleLabel.font = UIFont.systemFont(ofSize: 22.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.textColor = .ne_darkText
        name.font = UIFont.systemFont(ofSize: 22.0)
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ne_greyText
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logoutBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("退出登录", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.ne_darkText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action:  #selector(buttonEvent), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            header.widthAnchor.constraint(equalToConstant: 60),
            header.heightAnchor.constraint(equalToConstant: 60)
        ])
        header.clipsToBounds = true
        header.layer.cornerRadius = 30

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: header.rightAnchor, constant: 15),
            nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: header.topAnchor)
        ])

        view.addSubview(idLabel)
        NSLayoutConstraint.activate([
            idLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            idLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])

        let user = AuthorManager.shareInstance()?.getUserInfo()
        idLabel.text = "账号:\(user?.imAccid ?? "")"
        nameLabel.text = user?.nickname
        header.setTitle(CoreKitIMEngine.instance.imAccid)
        let color = UIColor.colorWithString(string: CoreKitEngine.instance.imAccid)
        header.backgroundColor = color
        

        
        let divider = UIView()
        view.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(hexString: "EFF1F4")
        NSLayoutConstraint.activate([
            divider.leftAnchor.constraint(equalTo: view.leftAnchor),
            divider.heightAnchor.constraint(equalToConstant: 6),
            divider.rightAnchor.constraint(equalTo: view.rightAnchor),
            divider.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 32)
        ])
        
        view.addSubview(logoutBtn)
        NSLayoutConstraint.activate([
            logoutBtn.topAnchor.constraint(equalTo: divider.bottomAnchor),
            logoutBtn.leftAnchor.constraint(equalTo: view.leftAnchor),
            logoutBtn.rightAnchor.constraint(equalTo: view.rightAnchor),
            logoutBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false
        super.viewWillAppear(animated)
    }
    
    @objc func buttonEvent() {
        AuthorManager.shareInstance()?.logout(withConfirm: "确认要退出登录吗？", withCompletion: {[weak self] user, error in
            if error != nil {
                self?.view.makeToast(error?.localizedDescription)
            }else {
                NIMSDK.shared().loginManager.logout { error in
                    NIMSDK.shared().qchatManager.logout { chatError in
                        if error != nil {
                            self?.view.makeToast(error?.localizedDescription)
                        }else {
                            print("logout success")
                            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
                        }
                    }
                }
            }
        })
    }

}
