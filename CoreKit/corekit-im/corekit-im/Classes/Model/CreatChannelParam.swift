//
//  CreatChannelParam.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/20.
//

import Foundation
import NIMSDK

public enum ChannelType: Int {
    case messageType = 0,customType = 100
}

public enum ChannelVisibleType {
    case isPublic
    case isPrivate
}

public struct CreatChannelParam {
    public var serverId: UInt64
    public var name: String
    public var topic: String?
    public var custom: String?
    public var visibleType: ChannelVisibleType = .isPublic
    public var type: ChannelType = .messageType
    
    public init(serverId: UInt64, name: String, topic: String?, visibleType: ChannelVisibleType) {
        self.serverId = serverId
        self.name = name
        self.topic = topic
        self.visibleType = visibleType
    }

    func toIMParam() -> NIMQChatCreateChannelParam {
        let imParam = NIMQChatCreateChannelParam()
        imParam.serverId = self.serverId
        imParam.name = self.name
        imParam.topic = self.topic ?? ""
        imParam.custom = self.custom ?? ""
        switch self.type {
        case .messageType:
            imParam.type = .msg
        default:
            imParam.type = .custom
        }
        switch self.visibleType {
        case .isPublic:
            imParam.viewMode = .public
        case .isPrivate:
            imParam.viewMode = .private
        }
        return imParam
    }
}
