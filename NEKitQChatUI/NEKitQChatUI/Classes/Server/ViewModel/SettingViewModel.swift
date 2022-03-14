//
//  SettingViewModel.swift
//  NEKitQChatUI
//
//  Created by yu chen on 2022/1/22.
//

import Foundation
import NEKitQChat

class SettingViewModel {
    
    let repo = QChatRepo()
    var permissions = [SettingModel]()
    init(){
        let member = SettingModel()
        member.title = localizable("qchat_member")
        member.cornerType = CornerType.topLeft.union(CornerType.topRight)
        permissions.append(member)
        let idGroup = SettingModel()
        idGroup.title = localizable("qchat_id_group")
        idGroup.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight)
        permissions.append(idGroup)
    }
}
