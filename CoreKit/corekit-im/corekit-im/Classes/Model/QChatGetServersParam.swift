//
//  QChatGetServersParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/9.
//

import Foundation
import NIMSDK

public struct QChatGetServersParam {
    
    public var serverIds:[NSNumber]?
    
    
    public init(serverIds:[NSNumber]) {
        self.serverIds = serverIds
    }
    
    
    func toIMParam() -> NIMQChatGetServersParam {
        let imParam = NIMQChatGetServersParam()
        imParam.serverIds = self.serverIds ?? [NSNumber]()
        return imParam
    }
}
