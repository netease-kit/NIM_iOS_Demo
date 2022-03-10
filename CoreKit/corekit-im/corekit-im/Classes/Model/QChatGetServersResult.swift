//
//  QChatGetServersResult.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/9.
//

import Foundation
import NIMSDK
public struct QChatGetServersResult {
    
    public var servers = [QChatServer]()
    
    init(serversResult: NIMQChatGetServersResult?) {
        guard let serversArray = serversResult?.servers else { return  }
        for server in serversArray {
            let itemModel = QChatServer(server: server)
            self.servers.append(itemModel)
        }
    }
}
