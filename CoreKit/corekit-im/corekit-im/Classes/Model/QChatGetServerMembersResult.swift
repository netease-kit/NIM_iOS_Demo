//
//  QChatGetServerMembersResult.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/9.
//

import Foundation
import NIMSDK

public struct QChatGetServerMembersResult {
    
    public var memberArray = [ServerMemeber]()
    /**
     * 是否还有下一页数据
     */
    public var hasMore:Bool?
    /**
     * 下一页的起始时间戳
     */
    public var nextTimetag:TimeInterval?

    
    /// 成员信息
    /// - Parameter memberData: 成员信息结果
    init(memberData:NIMQChatGetServerMembersResult?) {
        guard let memberArray = memberData?.memberArray else { return  }
       
        for member in memberArray {
            let itemModel = ServerMemeber(member)
            self.memberArray.append(itemModel)
        }
    }
    
    
    /// 分页成员信息
    /// - Parameter membersResult: 成员信息结果
    init(membersResult: NIMQChatGetServerMemberListByPageResult?) {
        
        guard let memberArray = membersResult?.memberArray else { return  }
        for member in memberArray {
            let itemModel = ServerMemeber(member)
            self.memberArray.append(itemModel)
        }
        self.hasMore = membersResult?.hasMore
        self.nextTimetag = membersResult?.nextTimetag
    }
    

}
