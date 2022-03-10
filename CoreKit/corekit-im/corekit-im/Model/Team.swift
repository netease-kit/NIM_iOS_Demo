//
//  File.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/11.
//

import Foundation
import NIMSDK

public enum TeamType {
    case normalTeam
    case advancedTeam
    case supereTeam
}

public struct Team {
    //FIXME:转换部分NIMTeam属性
    public var teamId: String?
    public var teamName: String?
    public var avatarUrl: String?
    public var thumbAvatarUrl: String?
    public var type: TeamType?
    /// 群拥有者ID 普通群拥有者就是群创建者,但是高级群可以进行拥有信息的转让
    public var owner: String?
    /// 群介绍
    public var intro: String?
    /// 群公告
    public var announcement: String?
    /// 群成员人数 这个值表示是上次登录后同步下来群成员数据,并不实时变化,必要时需要调用fetchTeamInfo:completion:进行刷新
    public var memberNumber: Int?
    /// 群等级 目前主要是限制群人数上限
    public var level: Int?
    /// 群创建时间
    public var createTime: TimeInterval?
    
    init(teamInfo: NIMTeam?) {
        self.teamId = teamInfo?.teamId
        self.teamName = teamInfo?.teamName
        self.avatarUrl = teamInfo?.avatarUrl
        self.thumbAvatarUrl = teamInfo?.thumbAvatarUrl
        switch teamInfo?.type {
        case .normal:
            self.type = .normalTeam
        case .advanced:
            self.type = .advancedTeam
        case .super:
            self.type = .supereTeam
        default:
            self.type = .normalTeam
        }
        self.owner = teamInfo?.owner
        self.intro = teamInfo?.intro
        self.announcement = teamInfo?.announcement
        self.memberNumber = teamInfo?.memberNumber
        self.level = teamInfo?.level
        self.createTime = teamInfo?.createTime
    }
  

}
