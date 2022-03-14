//
//  RoleStatusInfoExt.swift
//  NEKitCoreIM
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
import NEKitCoreIM

public struct RoleStatusInfoExt {
    public var status: RoleStatusInfo?
    public var title: String?
    
    public init(status: RoleStatusInfo?) {
        self.status = status
    }
}
