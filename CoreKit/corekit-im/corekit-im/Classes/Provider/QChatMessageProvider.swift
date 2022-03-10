//
//  QChatMessageObserver.swift
//  CoreKit-IM
//
//  Created by yu chen on 2022/2/27.
//

import Foundation
import NIMSDK

public protocol QChatMessageProviderDelegate: AnyObject {
    
    func onReceive(_ messages: [NIMQChatMessage])
    
    func onUnReadChange(_ unreads: [NIMQChatUnreadInfo]?, _ lastUnreads: [NIMQChatUnreadInfo]?)
}

public class QChatMessageProvider: NSObject, NIMQChatManagerDelegate, NIMEventSubscribeManagerDelegate {
    
    public static let shared = QChatMessageProvider()
    
    private let mutiDelegate = MultiDelegate<QChatMessageProviderDelegate>(strongReferences: false)
    
    override init(){
        super.init()
        NIMSDK.shared().qchatMessageManager.add(self)
    }
    
    public func addDelegate(_ delegate: QChatMessageProviderDelegate) {
        mutiDelegate.addDelegate(delegate)
    }
    
    public func removeDelegate(_ delegate: QChatMessageProviderDelegate) {
        mutiDelegate.removeDelegate(delegate)
    }
}

extension QChatMessageProvider: NIMQChatMessageManagerDelegate {
    
    public func onRecvMessages(_ messages: [NIMQChatMessage]) {
//        print("on recv message : ", messages)
        mutiDelegate.invokeDelegates { delegate in
            delegate.onReceive(messages)
        }
    }
    
    public func unreadInfoChanged(_ event: NIMQChatUnreadInfoChangedEvent) {
//        print("un read info change : ", event)
        mutiDelegate.invokeDelegates { delegate in
            delegate.onUnReadChange(event.unreadInfo, event.lastUnreadInfo)
        }
    }
    
}
