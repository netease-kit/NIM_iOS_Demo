//
//  UpdateServerMemberInfoParam.swift
//  CoreKit-IM
//
//  Created by yu chen on 2022/3/4.
//

import Foundation
import NIMSDK

public struct UpdateServerMemberInfoParam {
    
    public var serverId: UInt64?

    public var accid: String?

    public var nick: String?

    public var avatar: String?
    
    public init(){}
    
    func toImPara() -> NIMQChatUpdateServerMemberInfoParam {
        let param = NIMQChatUpdateServerMemberInfoParam()
        if let sid = serverId {
            param.serverId = sid
        }
        if let aid = accid {
            param.accid = aid
        }
        if let n = nick {
            param.nick = n
        }
        if let a = avatar {
            param.avatar = a
        }
        return param
    }
}
