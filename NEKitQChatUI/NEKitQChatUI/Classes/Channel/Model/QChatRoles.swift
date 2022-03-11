//
//  QChatRoles.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
import NEKitCoreIM

public enum roundedType {
    case none
    case top
    case bottom
    case all
}

public struct RoleModel {
    public var role: ChannelRole?
    public var member: MemberRole?
    public var title: String?
    public var corner: roundedType?
    public var isPlacehold: Bool = false
}

public struct QChatRoles {
    public var roles: [RoleModel] = [RoleModel]()
    public var timeTag: TimeInterval?
    public var pageSize: Int = 5

}
