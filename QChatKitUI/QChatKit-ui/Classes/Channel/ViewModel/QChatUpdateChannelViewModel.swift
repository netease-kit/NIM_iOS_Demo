//
//  QChatUpdateChannelViewModel.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/2/10.
//

import Foundation
import CoreKit_IM
import QChatKit

public class QChatUpdateChannelViewModel {
    public var channel: ChatChannel?
    //临时记录修改的值
    public var channelTmp: ChatChannel?
    init(channel:ChatChannel?) {
        self.channel = channel
        self.channelTmp = channel
    }
    
    func updateChannelInfo(completion: @escaping (NSError?, ChatChannel?) -> Void) {
        var param = UpdateChannelParam(channelId: channel?.channelId)
        param.name = channelTmp?.name
        param.topic = channelTmp?.topic
        param.custom = channelTmp?.custom
        QChatRepo().updateChannelInfo(param) { [weak self] error, channel in
            if error == nil {
                self?.channel = channel
            }
            completion(error, channel)
        }
    }
    
    func deleteChannel(completion: @escaping (NSError?) -> Void) {
        QChatChannelProvider.shared.deleteChannel(channelId: channel?.channelId, completion)
    }

}
