//
//  FindFriendViewController.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/13.
//

import UIKit

class FindFriendViewController: ContactBaseViewController, UITextFieldDelegate {
    
    let viewModel = FindFriendViewModel()
    let noResultView = UIView()
    let hasRequest = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加好友"
        setupUI()
    }
    
    func setupUI(){
        let searchBack = UIView()
        view.addSubview(searchBack)
        searchBack.backgroundColor = UIColor(hexString: "F2F4F5")
        searchBack.translatesAutoresizingMaskIntoConstraints = false
        searchBack.clipsToBounds = true
        searchBack.layer.cornerRadius = 4.0
        NSLayoutConstraint.activate([
            searchBack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            searchBack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            searchBack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchBack.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let searchImage = UIImageView()
        searchBack.addSubview(searchImage)
        searchImage.image = UIImage.ne_imageNamed(name: "search")
        searchImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchImage.centerYAnchor.constraint(equalTo: searchBack.centerYAnchor),
            searchImage.leftAnchor.constraint(equalTo: searchBack.leftAnchor, constant: 18),
            searchImage.widthAnchor.constraint(equalToConstant: 13),
            searchImage.heightAnchor.constraint(equalToConstant: 13)
        ])
        
        let searchInput = UITextField()
        searchBack.addSubview(searchInput)
        searchInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchInput.leftAnchor.constraint(equalTo: searchImage.rightAnchor, constant: 5),
            searchInput.rightAnchor.constraint(equalTo: searchBack.rightAnchor, constant: -18),
            searchInput.topAnchor.constraint(equalTo: searchBack.topAnchor),
            searchInput.bottomAnchor.constraint(equalTo: searchBack.bottomAnchor)
        ])
        searchInput.textColor = UIColor(hexString: "333333")
        searchInput.placeholder = "输入查找用户id"
        searchInput.font = UIFont.systemFont(ofSize: 14.0)
        searchInput.returnKeyType = .search
        searchInput.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text else {
            return false
        }
        if text.count <= 0 {
            return false
        }
        if self.hasRequest == false {
            startSearch(text)
        }
        return true
    }
    
    func startSearch(_ text: String){
        viewModel.searchFriend(text) { users, error in
            if error == nil {
                if let user = users?.first {
                    // go to detail
                    let userController =  ContactUserViewController(user: user)
                    self.navigationController?.pushViewController(userController, animated: true)
                }
            }else {
                self.view.makeToast(error?.localizedDescription)
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
