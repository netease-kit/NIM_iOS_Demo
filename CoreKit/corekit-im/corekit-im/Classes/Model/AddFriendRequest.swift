//
//  AddFriendRequest.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/12.
//

import Foundation

public enum OperationType {
//    添加好友 直接添加为好友,无需验证
    case add
//    请求添加好友
    case addRequest
//    通过添加好友请求
    case verify
//    拒绝添加好友请求
    case reject
}

public class AddFriendRequest {
    public var account: String = ""
    public var operationType: OperationType = OperationType.add
    public var meassage: String?

    public init() {}
//    convenience public init(account: String, operationType: OperationType, message: String?) {
//        self.account = account
//        self.operationType = operationType
//        self.meassage = message
//    }
}
