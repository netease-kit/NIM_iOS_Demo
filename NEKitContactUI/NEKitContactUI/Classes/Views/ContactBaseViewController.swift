//
//  ContactBaseViewController.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/13.
//

import UIKit

public class ContactBaseViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        edgesForExtendedLayout = []
        setupBackUI()
    }
    
    private func setupBackUI(){
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        let backItem = UIBarButtonItem(image: UIImage.ne_imageNamed(name: "backArrow"), style: .plain, target: self, action: #selector(backToPrevious))
        backItem.tintColor = UIColor(hexString: "333333")
        self.navigationItem.leftBarButtonItem = backItem
    }
    

    @objc func backToPrevious(){
        self.navigationController?.popViewController(animated: true)
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
