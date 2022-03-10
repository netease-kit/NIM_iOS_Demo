//
//  ChannelMembersParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/12.
//

import Foundation
import NIMSDK

public struct ChannelMembersParam {
    public var serverId: UInt64
    public var channelId: UInt64
    //timetag
    public var timeTag: TimeInterval?
    //每页个数
    public var limit: Int = 50
    
    public init(serverId: UInt64, channelId: UInt64) {
        self.serverId = serverId
        self.channelId = channelId
    }
    
    public func toIMParam() -> NIMQChatGetChannelMembersByPageParam {
        let imParam = NIMQChatGetChannelMembersByPageParam();
        imParam.serverId = serverId
        imParam.channelId = channelId
        imParam.timeTag = timeTag ?? 0
        imParam.limit = limit
        return imParam
    }
}
