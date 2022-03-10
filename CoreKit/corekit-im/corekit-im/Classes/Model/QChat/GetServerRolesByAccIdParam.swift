//
//  GetServerRolesByAccIdParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/13.
//

import Foundation
import NIMSDK

public struct GetServerRolesByAccIdParam {
    public var serverId: UInt64?
    public var accid: String?
    public var timeTag: TimeInterval?
    public var limit: Int?
    
    public init(serverId: UInt64?, accid: String?, timeTag: TimeInterval? = 0, limit: Int? = 50) {
        self.serverId = serverId
        self.accid = accid
        self.timeTag = timeTag
        self.limit = limit
    }
    
    public func toIMParam() -> NIMQChatGetServerRolesByAccidParam {
        let imParam = NIMQChatGetServerRolesByAccidParam()
        if let sid = serverId {
            imParam.serverId = sid
        }
        if let aid = accid {
            imParam.accid = aid
        }
        if let l = limit {
            imParam.limit = l
        }
        if let t = timeTag {
            imParam.timeTag = t
        }
        return imParam
    }
}
