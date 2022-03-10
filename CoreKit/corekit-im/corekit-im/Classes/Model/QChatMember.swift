//
//  QChatMember.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/9.
//

import Foundation
import NIMSDK


public enum QChatServerMemberType {
    case common//普通成员
    case owner//所有者
}

public struct QChatMember{
    
    public var serverId: UInt64?
    public var appId: NSInteger?
    public var accid: String?
    public var nick: String?
    public var avatar: String?
    public var inviter: String?
    public var custom: String?
    public var type: QChatServerMemberType?
    public var joinTime: TimeInterval?
    public var validFlag: Bool?
    public var createTime: TimeInterval?
    public var updateTime: TimeInterval?
    
    
    init(member: NIMQChatServerMember?) {
        self.serverId = member?.serverId
        self.appId = member?.appId
        self.accid = member?.accid
        self.nick = member?.nick
        self.avatar = member?.avatar
        self.inviter = member?.inviter
        self.custom = member?.custom
        
        switch member?.type {
        case .common:
            self.type = .common
        case .owner:
            self.type = .owner
        default:
            self.type = .common
        }
        self.validFlag = member?.validFlag
        self.joinTime = member?.joinTime
        self.createTime = member?.createTime
        self.updateTime = member?.updateTime
    }
}
