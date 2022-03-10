//
//  UpdateServerParam.swift
//  CoreKit-IM
//
//  Created by yu chen on 2022/2/14.
//

import Foundation
import NIMSDK

public struct UpdateServerParam {
    
    public var serverId: UInt64?
    //名称，必填
    public var name: String?
    
    public var icon: String?

    public var custom: String?
    //邀请模式
    public var inviteMode: QChatServerInviteMode?
    //申请模式
    public var applyMode: QChatServerApplyMode?

    public init(name:String,icon:String?) {
        self.name = name
        self.icon = icon
    }
    
    func toImParam() ->  NIMQChatUpdateServerParam{
        let imParam = NIMQChatUpdateServerParam()
        if let n = name {
            imParam.name = n
        }
        if let i = icon {
            imParam.icon = i
        }
        if let sid = serverId {
            imParam.serverId = sid
        }
        if let c = custom {
            imParam.custom = c
        }
        switch self.inviteMode {
        case .autoEnter:
            imParam.inviteMode = 1
        default:
            imParam.inviteMode = 0
        }
        
        switch self.applyMode {
        case .needApprove:
            imParam.applyMode = 1
        default:
            imParam.applyMode = 0
        }
        return imParam
    }
}
