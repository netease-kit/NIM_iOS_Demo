//
//  QChatInviteServerMembersParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/22.
//

import Foundation
import NIMSDK
public struct QChatInviteServerMembersParam {
    //圈组服务器ID
    public var serverId: UInt64?
    //邀请对象的账号数组
    public var accids: [String]?
    //附言（最长5000）
    public var postscript: String?

    public init(serverId:UInt64,accids:[String]){
        self.serverId = serverId
        self.accids = accids
    }
    
    func toImParam() ->  NIMQChatInviteServerMembersParam{
        let imParam = NIMQChatInviteServerMembersParam()
        if let id = self.serverId {
            imParam.serverId = id
        }
        if let accids = self.accids {
            imParam.accids = accids
        }
        imParam.postscript = self.postscript
        return imParam
    }
    
    
    
}
