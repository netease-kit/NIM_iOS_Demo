//
//  PermissionCellModel.swift
//  QChatKit-UI
//
//  Created by chenyu on 2022/2/6.
//

import Foundation

class PermissionCellModel {
    
    weak var permission: PermissionModel?
    var permissionKey: String?
    var showName: String?
    var cornerType = CornerType.none
    var hasPermission = false
}
