//
//  ContactRouter.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/14.
//

import Foundation
import TPRouter_Swift
public let ValidationMessageRouter = "xkit://contact.validation.view"
public let ContactPersonRouter = "xkit://contact.person.view"
public let ContactBlackListRouter = "xkit://contact.blacklist.view"
public let ContactGroupRouter = "xkit://contact.group.view"
public let ContactComputerRouter = "xkit://contact.computer.view"

public struct ContactRouter {
    public static func register() {
        Router.shared.register("goToContactSelectedVC") { param in
            print("param:\(param)")
            let nav = param["nav"] as? UINavigationController
            let contactSelectVC = ContactsSelectedViewController()
            nav?.pushViewController(contactSelectVC, animated: true)
        }
    }
    
}
