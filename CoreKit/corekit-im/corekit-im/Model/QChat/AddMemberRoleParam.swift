//
//  AddMemberRoleParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/14.
//

import Foundation
import NIMSDK

public struct AddMemberRoleParam {
    public var serverId: UInt64?
    public var channelId: UInt64?
    public var accid: String?
    
    public init(serverId: UInt64?, channelId: UInt64?, accid: String?) {
        self.serverId = serverId
        self.channelId = channelId
        self.accid = accid
    }
    
    public func toIMParam() -> NIMQChatAddMemberRoleParam {
        let imParam = NIMQChatAddMemberRoleParam()
        imParam.serverId = serverId ?? 0
        imParam.channelId = channelId ?? 0
        imParam.accid = accid ?? ""
        return imParam
    }
}
