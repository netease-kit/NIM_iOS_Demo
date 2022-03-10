//
//  MarkMessageReadParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/3/3.
//

import Foundation
import NIMSDK

public struct MarkMessageReadParam {
    
    public var serverId: UInt64?
    public var channelId: UInt64?
    public var ackTimestamp: TimeInterval?

    
    public init(serverId: UInt64, channelId: UInt64) {
        self.serverId = serverId
        self.channelId = channelId
    }
    
    public func toImParam() ->  NIMQChatMarkMessageReadParam {
        let imParam = NIMQChatMarkMessageReadParam()

        if let sid = serverId {
            imParam.serverId = sid
        }
        
        if let cid = channelId {
            imParam.channelId = cid
        }
        if let time = ackTimestamp {
            imParam.ackTimestamp = time
        }
        return imParam

    }
}
