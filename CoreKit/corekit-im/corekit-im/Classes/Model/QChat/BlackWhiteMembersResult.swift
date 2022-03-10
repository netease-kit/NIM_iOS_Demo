//
//  BlackWhiteMembersResult.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/18.
//

import Foundation
import NIMSDK

public struct BlackWhiteMembersResult {
    public var memberArray = [ServerMemeber]()
    
    init(result: NIMQChatGetExistingChannelBlackWhiteMembersResult?) {
        if let members = result?.memberArray {
            for member in members {
                self.memberArray.append(ServerMemeber(member))
            }
        }
    }
}
