//
//  QChatServer.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/8.
//

import Foundation
import NIMSDK

public class QChatServer {
    public var serverId: UInt64?
    public var appId: NSInteger?
    public var name: String?
    public var icon: String?
    public var custom: String?
    public var owner: String?
    public var memberNumber: NSInteger?
    public var inviteMode: QChatServerInviteMode?
    public var applyMode: QChatServerApplyMode?
    public var validFlag: Bool?
    public var createTime: TimeInterval?
    public var updateTime: TimeInterval?
    public var hasUnread = false
//    public var unreadCount: UInt = 0
//    public var hasGetUnread = false
    
    
    init(server: NIMQChatServer?) {
        self.serverId = server?.serverId
        self.appId = server?.appId
        self.name = server?.name
        self.icon = server?.icon
        self.custom = server?.custom
        self.owner = server?.owner
        self.memberNumber = server?.memberNumber ?? 0
        switch server?.inviteMode {
        case .autoEnter:
            self.inviteMode = .autoEnter
        case .needApprove:
            self.inviteMode = .needApprove
        default:
            self.inviteMode = .needApprove
        }
        
        
        switch server?.applyMode {
        case .autoEnter:
            self.applyMode = .autoEnter
        case .needApprove:
            self.applyMode = .needApprove
        default:
            self.applyMode = .autoEnter
        }

        self.validFlag = server?.validFlag
        self.createTime = server?.createTime
        self.updateTime = server?.updateTime
    }
}
