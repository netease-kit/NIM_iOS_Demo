//
//  DeleteServerRoleParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
import NIMSDK

public struct RemoveChannelRoleParam {
    public var serverId: UInt64?
    public var channelId: UInt64?
    public var roleId: UInt64?
    
    public init() {}
    public func toImParam() -> NIMQChatRemoveChannelRoleParam {
        let imParam = NIMQChatRemoveChannelRoleParam()
        imParam.serverId = self.serverId ?? 0
        imParam.roleId = self.roleId ?? 0
        imParam.channelId = self.channelId ?? 0
        return imParam
    }
    
}
