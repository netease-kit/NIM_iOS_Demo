//
//  GetChannelUnreadInfosParam.swift
//  CoreKit-IM
//
//  Created by yu chen on 2022/3/1.
//

import Foundation
import NIMSDK

public struct ChannelIdInfo{
    
    public var channelId: UInt64?
    public var serverId: UInt64?
    public init(){}
    func toImParam() -> NIMQChatChannelIdInfo{
        let channelIdInfo = NIMQChatChannelIdInfo()
        if let cid = channelId {
            channelIdInfo.channelId = cid
        }
        if let sid = serverId {
            channelIdInfo.serverId = sid
        }
        return channelIdInfo
    }
}

public struct GetChannelUnreadInfosParam {
    
    public var targets: [ChannelIdInfo]?
    
    public init(){}
    
    func toImParam() -> NIMQChatGetChannelUnreadInfosParam{
        let param = NIMQChatGetChannelUnreadInfosParam()
        var infos = [NIMQChatChannelIdInfo]()
        targets?.forEach({ info in
            infos.append(info.toImParam())
        })
        param.targets = infos
        return param
    }
}
