//
//  GetExistingAccidsOfMemberRolesParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/21.
//

import Foundation
import NIMSDK

public struct GetExistingAccidsOfMemberRolesParam {
    
    public var serverId: UInt64
    public var channelId: UInt64
    public var accids: [String]
    
    public init(serverId: UInt64, channelId: UInt64, accids: [String]) {
        self.serverId = serverId
        self.channelId = channelId
        self.accids = accids
    }
    
    func toIMParam() -> NIMQChatGetExistingAccidsOfMemberRolesParam {
        let imParam = NIMQChatGetExistingAccidsOfMemberRolesParam()
        imParam.serverId = serverId
        imParam.channelId = channelId
        imParam.accids = accids
        return imParam
    }
}
