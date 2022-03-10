//
//  ChannelMembersResult.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/12.
//

import Foundation
import NIMSDK

public struct ChannelMembersResult {
    
    public var memberArray: [ServerMemeber]?
    
    /// 是否还有下一页数据
    public var hasMore: Bool?
    
    /// 下一页的起始时间戳
    public var nextTimetag: TimeInterval?
    
    init(){}
    init(memberResult: NIMQChatGetChannelMembersByPageResult?) {
        self.hasMore = memberResult?.hasMore
        self.nextTimetag = memberResult?.nextTimetag
        if let members = memberResult?.memberArray {
            var array = [ServerMemeber]()
            for member in members {
                array.append(ServerMemeber(member))
            }
            self.memberArray = array
        }
    }
    init(whiteMemberResult: NIMQChatGetChannelBlackWhiteMembersByPageResult?) {
        self.hasMore = whiteMemberResult?.hasMore
        self.nextTimetag = whiteMemberResult?.nextTimetag
        if let members = whiteMemberResult?.memberArray {
            var array = [ServerMemeber]()
            for member in members {
                array.append(ServerMemeber(member))
            }
            self.memberArray = array
        }
    }
}
