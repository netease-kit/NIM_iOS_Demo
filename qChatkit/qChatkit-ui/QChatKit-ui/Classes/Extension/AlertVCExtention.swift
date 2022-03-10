//
//  AlertVCExtention.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/10.
//

import Foundation
extension UIAlertController {
    class func reconfimAlertView(title: String?, message: String?, confirm: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: localizable("cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: localizable("ok"), style: .default) { action in
            confirm()
        })
        return alert
    }
}
