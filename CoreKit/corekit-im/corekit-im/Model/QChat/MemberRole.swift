//
//  MemberRole.swift
//  CoreKit-IM
//
//  Created by yu chen on 2022/2/10.
//

import Foundation
import NIMSDK


public struct MemberRole {
    /**
     *  服务器id
     */
    public var serverId: UInt64?
    /**
     * 定制权限id
     */
    public var roleId: UInt64?
    /**
     * 用户id
     */
    public var accid: String?
    /**
     * 频道id
     */
    public var channelId: UInt64?
    /**
     * 该身份组各资源的权限状态
     */
    public var auths: [RoleStatusInfo]?

    /**
     * 创建时间
     */
    public var createTime: Double?
    /**
     * 更新时间
     */
    public var updateTime: Double?
    /**
     * 昵称
     * */
    public var nick: String?
    /**
     * 头像
     */
    public var avatar: String?
    /**
     * 自定义字段
     */
    public var custom: String?
    /**
     * 成员类型
     */
    public var type: ServerMemberType?
    /**
     * 加入时间
     */
    public var joinTime: Double?
    /**
     * 邀请者accid
     */
    public var inviter: String?
    
    init(aid: String){
        accid = aid
    }
    
    init(member: NIMQChatMemberRole?) {
        self.serverId = member?.serverId
        self.roleId = member?.roleId
        self.accid = member?.accid
        self.channelId = member?.channelId
        if let authsTmp = member?.auths {
            var auths = [RoleStatusInfo]()
            for a in authsTmp {
                auths.append(RoleStatusInfo(info: a))
            }
            self.auths = auths
        }
        self.createTime = member?.createTime
        self.updateTime = member?.updateTime
        self.nick = member?.nick
        self.avatar = member?.avatar
        self.custom = member?.custom
        self.type = member?.type.convertMeberType()
        self.joinTime = member?.joinTime
        self.inviter = member?.inviter
        
    }
}

