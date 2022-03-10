//
//  GetServersByPageParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/8.
//

import Foundation
import NIMSDK
public struct GetServersByPageParam {
    
    /// 时间戳
    public var timeTag:TimeInterval?
    
    /// 条数限制
    public var limit: Int?
    
    public init(timeTag:TimeInterval,limit:Int) {
        self.timeTag = timeTag
        self.limit = limit
    }
    
    func toIMParam() -> NIMQChatGetServersByPageParam {
        let imParam = NIMQChatGetServersByPageParam()
        imParam.timeTag = self.timeTag ?? 0
        imParam.limit = limit ?? 0
        return imParam
    }
    

}
