//
//  QChatApplyServerJoinParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/9.
//

import Foundation
import NIMSDK

public struct QChatApplyServerJoinParam {
    
    //申请加入的服务器Id
    public var serverId:UInt64
    //附言（最长5000）
    public var postscript:String?
    

    public init(serverId:UInt64) {
        self.serverId = serverId
    }
    
    func toIMParam() -> NIMQChatApplyServerJoinParam {
        let imParam = NIMQChatApplyServerJoinParam()
        imParam.serverId = self.serverId
        imParam.postscript = self.postscript ?? ""
        return imParam
    }
}
