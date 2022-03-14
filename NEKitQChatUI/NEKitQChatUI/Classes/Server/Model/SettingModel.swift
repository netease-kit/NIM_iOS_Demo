//
//  SettingModel.swift
//  NEKitQChatUI
//
//  Created by yu chen on 2022/1/22.
//

import Foundation

class SettingModel {
    var title: String?
    var cornerType: CornerType = CornerType.bottomLeft.union(CornerType.bottomRight).union(CornerType.topLeft).union(CornerType.topRight)
}
