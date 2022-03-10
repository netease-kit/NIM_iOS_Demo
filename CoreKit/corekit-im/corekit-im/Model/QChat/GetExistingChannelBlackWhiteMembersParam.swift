//
//  GetExistingChannelBlackWhiteMembersParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/18.
//

import Foundation
import NIMSDK

public struct GetExistingChannelBlackWhiteMembersParam {
    public var serverId: UInt64?
    public var channelId: UInt64?
    public var type: ChannelMemberRoleType?
    public var accIds:[String]?
    
    public init(serverId: UInt64?, channelId: UInt64?, type: ChannelMemberRoleType?, accIds:[String]?) {
        self.serverId = serverId
        self.channelId = channelId
        self.type = type
        self.accIds = accIds
    }
    
    func toIMParam() -> NIMQChatGetExistingChannelBlackWhiteMembersParam {
        let imParam = NIMQChatGetExistingChannelBlackWhiteMembersParam()
        imParam.serverId = serverId ?? 0
        imParam.channelId = channelId ?? 0
        if self.type == .white {
            imParam.type = .white
        }else {
            imParam.type = .black
        }
        imParam.accIds = accIds ?? [String]()
        return imParam
    }
}
