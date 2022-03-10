//
//  NEBaseViewController.swift
//  ContactKit-UI
//
//  Created by yuanyuan on 2022/1/21.
//

import UIKit


open class NEBaseViewController: UIViewController {
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupBackUI()

    }
    
    private func setupBackUI(){
        let image = UIImage.ne_imageNamed(name: "backArrow")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backEvent))
    }
    
    @objc func backEvent() {
        self.navigationController?.popViewController(animated: true)
    }

}
