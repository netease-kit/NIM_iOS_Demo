//
//  CreateServerResult.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/8.
//

import Foundation
import NIMSDK
public struct CreateServerResult {

    public var server:QChatServer?
    
    init(serverResult: NIMQChatCreateServerResult?) {
        self.server = QChatServer(server: serverResult?.server)
    }
    
}
