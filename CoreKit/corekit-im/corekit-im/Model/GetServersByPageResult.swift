//
//  GetServersByPageResult.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/8.
//

import Foundation
import NIMSDK

public struct GetServersByPageResult {
    
    public var servers = [QChatServer]()
    
    init(serversResult: NIMQChatGetServersByPageResult?) {
        
        guard let serverArray = serversResult?.servers else { return  }
       
        for server in serverArray {
            let itemModel = QChatServer(server: server)
            self.servers.append(itemModel)
        }
    }
}
