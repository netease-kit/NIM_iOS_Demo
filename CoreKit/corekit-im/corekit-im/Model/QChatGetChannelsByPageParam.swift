//
//  QChatGetChannelsByPageParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/10.
//

import Foundation
import NIMSDK

public struct QChatGetChannelsByPageParam {
    
    //服务器id
    public var serverId: UInt64?

    /// 时间戳
    public var timeTag:TimeInterval = 0
    
    /// 条数限制
    public var limit:Int = 20
    
    public init(timeTag:TimeInterval,serverId:UInt64) {
        self.serverId = serverId
        self.timeTag = timeTag
    }
    
   public func toIMParam() -> NIMQChatGetChannelsByPageParam {
        let imParam = NIMQChatGetChannelsByPageParam()
        
        if let serverId = self.serverId {
            imParam.serverId = serverId
        }
        imParam.timeTag = self.timeTag
        imParam.limit = self.limit
        return imParam
    }
}
