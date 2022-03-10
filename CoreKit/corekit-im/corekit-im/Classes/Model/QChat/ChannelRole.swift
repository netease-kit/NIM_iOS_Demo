//
//  File.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/8.
//

import Foundation
import NIMSDK

public enum channelRoleType {
    case everyone
    case custom
}

public struct ChannelRole {
    public var serverId: UInt64?
    public var roleId: UInt64?
    public var parentRoleId: UInt64?
    public var channelId: UInt64?
    public var name: String?
    public var type: channelRoleType?
    public var icon: String?
    
    public var ext: String?
    public var auths: [RoleStatusInfo]?
    public var createTime: TimeInterval?
    public var updateTime: TimeInterval?
    public init() {}
    
    init(role: NIMQChatChannelRole?) {
        serverId = role?.serverId
        roleId = role?.roleId
        parentRoleId = role?.parentRoleId
        channelId = role?.channelId
        name = role?.name
        
        type = role?.type == .custom ? .custom : .everyone
        icon = role?.icon
        ext = role?.ext
        
        createTime = role?.createTime
        updateTime = role?.updateTime
        guard let authl = role?.auths else {
            return
        }
        var authList: [RoleStatusInfo] = []
        for auth in authl {
            authList.append(RoleStatusInfo(info: auth))
            auths = authList
        }
    }
}


