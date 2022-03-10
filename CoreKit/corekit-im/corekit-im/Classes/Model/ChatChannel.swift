//
//  ChatChannel.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/20.
//

import Foundation
import NIMSDK

public struct ChatChannel {
    
    public var channelId: UInt64?
    public var serverId: UInt64?
    public var appId: Int?
    public var name: String?
    public var topic: String?
    public var visibleType: ChannelVisibleType?
    public var custom: String?
    public var type: ChannelType?
    public var validflag: Bool?
    public var createTime: TimeInterval?
    public var updateTime: TimeInterval?
    public init() {}
    
    init(channel: NIMQChatChannel?) {
        self.channelId = channel?.channelId
        self.serverId = channel?.serverId
        self.appId = channel?.appId
        self.name = channel?.name
        self.topic = channel?.topic
        self.custom = channel?.custom
        self.type = .messageType
        switch channel?.type {
        case .msg:
            self.type = .messageType
        case .custom:
            self.type = .customType
        default:
            self.type = .messageType
        }
        switch channel?.viewMode {
        case .public:
            self.visibleType = .isPublic
        case .private:
            self.visibleType = .isPrivate
        default:
            self.visibleType = .isPublic
        }
        
        self.validflag = channel?.validflag
        self.createTime = channel?.createTime
        self.updateTime = channel?.updateTime
    }

}
