//
//  File.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/3/2.
//

import NIMSDK
import Foundation
public struct GetMessageHistoryParam {
    var serverId: UInt64
    var channelId: UInt64
//    message number per page
    public var limit: Int = 100
//    last message in last page
    public var lastMsg: NIMQChatMessage?
    
    public init(serverId: UInt64, channelId: UInt64) {
        self.serverId = serverId
        self.channelId = channelId
    }
    
    func toImParam() ->  NIMQChatGetMessageHistoryParam {
        let imParam = NIMQChatGetMessageHistoryParam()
        imParam.serverId = self.serverId
        imParam.channelId = self.channelId
        imParam.limit = Foundation.NSNumber(integerLiteral: self.limit)
        imParam.reverse = false
        
        if let msg = self.lastMsg {
            imParam.toTime = Foundation.NSNumber(floatLiteral: msg.timestamp)
            imParam.excludeMsgId = Foundation.NSNumber(integerLiteral: Int(msg.serverID) ?? 0)
        }
        print("imParam:\(imParam.toTime) \(imParam.excludeMsgId)")
        return imParam
    }
}
