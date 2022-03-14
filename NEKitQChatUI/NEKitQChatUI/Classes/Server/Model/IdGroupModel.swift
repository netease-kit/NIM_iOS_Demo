//
//  IdGroupModel.swift
//  NEKitQChatUI
//
//  Created by yu chen on 2022/1/25.
//

import Foundation
import NEKitCoreIM

class IdGroupModel {
    var idName: String?
    var subTitle: String?
//    {
//        didSet {
//            if let s = subTitle, s == "0人" {
//                
//            }
//        }
//    }
    var uid: Int?
    var isSelect = false
    var cornerType: CornerType = .none
    var role: ServerRole?
    var hasPermission = false
    
    public init(){}
    
    public init(_ serverRole: ServerRole){
        role = serverRole
        idName = serverRole.name
        if let type = serverRole.type, type == .everyone {
            subTitle = localizable("qchat_group_default_permission")
        }else if let type = serverRole.type, type == .custom {
            subTitle = "\(serverRole.memberCount ?? 0)人"
        }
        
//        if let s = subTitle, s == "0人" {
//            
//        }
    }
}
