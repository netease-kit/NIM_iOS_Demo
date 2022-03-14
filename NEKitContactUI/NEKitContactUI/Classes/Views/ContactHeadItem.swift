//
//  ContactHeadItem.swift
//  NEKitContactUI
//
//  Created by yuanyuan on 2022/1/6.
//

import Foundation

public class ContactHeadItem {
    public var name: String?
    public var imageName: String?
    public var router: String
    
    init(name: String, imageName: String?, router: String) {
        self.name = name
        self.imageName = imageName
        self.router = router
    }
}
