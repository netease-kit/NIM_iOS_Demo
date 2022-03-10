//
//  AddChannelRoleParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
import NIMSDK
public struct AddChannelRoleParam {
    public var serverId: UInt64
    public var channelId: UInt64
    public var parentRoleId: UInt64
    public init(serverId: UInt64, channelId: UInt64, parentRoleId: UInt64) {
        self.serverId = serverId
        self.channelId = channelId
        self.parentRoleId = parentRoleId
    }
    func toImParam() -> NIMQChatAddChannelRoleParam {
        let imParam = NIMQChatAddChannelRoleParam()
        imParam.serverId = self.serverId
        imParam.channelId = self.channelId
        imParam.parentRoleId = UInt64(self.parentRoleId)
        return imParam
    }
}
