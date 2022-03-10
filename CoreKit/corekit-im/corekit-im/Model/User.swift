//
//  User.swift
//  CoreKit
//
//  Created by yuanyuan on 2022/1/5.
//

import Foundation
import NIMSDK


public struct User {
    public var userId: String?
    public var alias: String?
    public var ext: String?
    public var serverExt: String?
    public var userInfo: UserInfo?
    public var imageName: String?
    public init() {}
    init(user: NIMUser?) {
        self.userId = user?.userId
        self.alias = user?.alias
        self.ext = user?.ext
        self.serverExt = user?.serverExt
        self.userInfo = UserInfo(userInfo: user?.userInfo)
    } 
}

