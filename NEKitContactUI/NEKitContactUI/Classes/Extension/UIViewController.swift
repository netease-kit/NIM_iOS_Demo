//
//  UIViewController.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/3/7.
//

import Foundation

extension UIViewController {
    typealias AlertCallBack = () -> Void
    func showAlert(title: String = localizable("alert_tip"), message: String?, sureText: String = localizable("alert_sure"), cancelText: String = localizable("alert_cancel"), _ sureBack: @escaping AlertCallBack, cancelBack: AlertCallBack? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        let cancelAction = UIAlertAction(title: cancelText, style: .default) { action in
            if let block = cancelBack {
                block()
            }
        }
        alertController.addAction(cancelAction)
        let sureAction = UIAlertAction(title: sureText, style: .default) { action in
            sureBack()
        }
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
}
