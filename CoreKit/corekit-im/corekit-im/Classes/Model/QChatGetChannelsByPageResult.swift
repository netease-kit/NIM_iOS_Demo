//
//  QChatGetChannelsByPageResult.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/10.
//

import Foundation
import NIMSDK
public struct QChatGetChannelsByPageResult{
    
    public var channels = [ChatChannel]()
    //是否还有下一页数据
    public var hasMore:Bool = false
    //下一页的起始时间戳
    public var nextTimetag:TimeInterval = 0

    
    public init(channelsResult: NIMQChatGetChannelsByPageResult?) {
        
        guard let channelArray = channelsResult?.channels else { return  }
        for channel in channelArray {
            let itemModel = ChatChannel(channel: channel)
            self.channels.append(itemModel)
        }
        
        if let hasMore = channelsResult?.hasMore {
            self.hasMore = hasMore
        }
        if let nextTimeTag = channelsResult?.nextTimetag {
            self.nextTimetag = nextTimeTag
        }
    }
}
