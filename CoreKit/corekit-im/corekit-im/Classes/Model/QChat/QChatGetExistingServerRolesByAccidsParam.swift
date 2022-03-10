//
//  QChatGetExistingAccidsInServerRoleParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/21.
//

import Foundation

import NIMSDK
public struct QChatGetExistingAccidsInServerRoleParam {
    public var serverId: UInt64
    public var accids:[String]?
    
    public init(serverId: UInt64, accids: [String]) {
        self.serverId = serverId
        self.accids = accids
    }
    
    
    func toImParam() -> NIMQChatGetExistingAccidsInServerRoleParam {
        let imParam = NIMQChatGetExistingAccidsInServerRoleParam()
        imParam.serverId = self.serverId
        if let accidArray = self.accids {
            imParam.accids = accidArray
        }
        return imParam
    }
}
