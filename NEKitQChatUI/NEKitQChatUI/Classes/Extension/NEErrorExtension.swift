//
//  NEErrorExtension.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
extension NSError {
    class func paramError() -> NSError {
        return NSError(domain: "com.qchat.doamin", code: 600, userInfo: ["message":localizable("param_error")])
    }
}
