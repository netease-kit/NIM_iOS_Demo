//
//  Notification.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/11.
//

import Foundation
import NIMSDK

/// eee
public enum NotificationType {
//    申请入群
    case teamApply
//    拒绝入群
    case teamApplyReject
//    邀请入群
    case teamInvite
//    拒绝入群邀请
    case teamInviteReject
//    添加好友 直接通过
    case addFriendDirectly
//    添加好友 需要对方同意
    case addFriendRequest
//    同意添加好友
    case addFriendVerify
//    拒绝添加好友
    case addFriendReject
//    申请入超大群
    case superTeamApply
//    拒绝入超大群
    case superTeamApplyReject
//    邀请入超大群
    case superTeamInvite
//    拒绝入超大群邀请
    case superTeamInviteReject
}

public enum IMHandleStatus: NSInteger {
    case HandleTypePending = 0
    case HandleTypeOk
    case HandleTypeNo
    case HandleTypeOutOfDate
}

public class XNotification {
    /// 操作者名字 只有NotificationType为addFriend相关操作有值
    public var sourceName: String?
    /// 目标名字,群名或者是用户名 只有群和高级群相关操作有值
    public var targetName: String?
    /// 通知 ID
    public var notificationId: Int64?
    /// 通知类型
    public var type: NotificationType?
    /// 时间戳
    public var timestamp: TimeInterval?
    /// 操作者
    public var sourceID: String?
    /// 目标ID,群ID或者是用户ID
    public var targetID: String?
    /// 附言
    public var postscript: String?
    /// 是否已读 修改这个属性并不会修改 db 中的数据
    public var read: Bool?
    /// 消息处理状态 修改这个属性,后台会自动更新 db 中对应的数据,SDK 调用者可以使用这个值来持久化他们对消息的处理结果,默认为 0
    private var handleStatus: Int {
        get {
            return imNotification?.handleStatus ?? 0
        }
        set(newStatus) {
            imNotification?.handleStatus = newStatus
        }
    }
    /// 系统通知下发的自定义扩展信息
    public var notifyExt: String?
    /// 附件 额外信息,只有 好友添加 这个通知有附件 好友添加的 attachment 为 NIMUserAddAttachment
//    public var attachment: UserAddAttachment?
    /// 服务器扩展 只有type为添加好友相关类型是有值
    public var serverExt: String?
    /// 缓存IMSDK的通知
    private var imNotification: NIMSystemNotification?
    
    init(notification: NIMSystemNotification?) {
        self.imNotification = notification
        self.notificationId = notification?.notificationId
        switch notification?.type {
        case .teamApply:
            self.type = .teamApply
        case .teamApplyReject:
            self.type = .teamApplyReject
        case .teamInvite:
            self.type = .teamInvite
        case .teamIviteReject:
            self.type = .teamInviteReject
        case .friendAdd:
            let attach = notification?.attachment as! NIMUserAddAttachment
            self.serverExt = attach.serverExt
            switch attach.operationType {
            case .add:
                self.type = .addFriendDirectly
            case .request:
                self.type = .addFriendRequest
            case .verify:
                self.type = .addFriendVerify
            case .reject:
                self.type = .addFriendReject
            default:
                self.type = .addFriendDirectly
            }
        case .superTeamApply:
            self.type = .superTeamApply
        case .superTeamApplyReject:
            self.type = .superTeamApplyReject
        case .superTeamInvite:
            self.type = .superTeamInvite
        case .superTeamIviteReject:
            self.type = .superTeamInviteReject
        default:
            self.type = .addFriendDirectly
        }
        self.timestamp = notification?.timestamp
        self.sourceID = notification?.sourceID
        self.targetID = notification?.targetID
        
        self.postscript = notification?.postscript
        self.read = notification?.read
        self.notifyExt = notification?.notifyExt
        self.sourceName = self.sourceID
    }
    
}
