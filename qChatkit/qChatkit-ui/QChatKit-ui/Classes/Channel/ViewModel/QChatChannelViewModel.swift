//
//  QChatChannelViewModel.swift
//  QChatKit-ui
//
//  Created by yuanyuan on 2022/1/21.
//

import Foundation
import CoreKit_IM

public class QChatChannelViewModel {
    public var serverId: UInt64
    public var name: String?
    public var topic: String?
    public var type: ChannelType = .messageType
    public var isPrivate: Bool = false
    public init(serverId: UInt64) {
        self.serverId = serverId
    }
    
    public init() {
        self.serverId = 0
    }
    
    public func createChannel(_ completion: @escaping (NSError?, ChatChannel?)->()) {
        let  visibleType: ChannelVisibleType = self.isPrivate ? .isPrivate : .isPublic
        let param = CreatChannelParam(serverId: serverId, name: name ?? "", topic: topic, visibleType: visibleType)
        QChatChannelProvider.shared.createChannel(param: param) { error, channel in
            completion(error, channel)
        }
    }
    
    public func getChannelsByPage(parameter:QChatGetChannelsByPageParam,_ completion: @escaping (NSError?, QChatGetChannelsByPageResult?)->()){
        QChatChannelProvider.shared.getChannelsByPage(param: parameter) { error, channelResult in
            completion(error,channelResult)
        }
    }
}
