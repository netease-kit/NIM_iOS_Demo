//
//  QChatSystemMessageProvider.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/23.
//

import Foundation
import NIMSDK

public class QChatSystemMessageProvider: NSObject {
    public static let shared = QChatSystemMessageProvider()
    private override init(){
        super.init()
    }
    
    public func sendMessage(message:NIMQChatMessage, session: NIMSession, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().qchatMessageManager.send(message, to: session) { error in
            completion(error)
        }
    }

    public func getMessageHistory(param: GetMessageHistoryParam, _ completion: @escaping (Error?, [NIMQChatMessage]?) -> Void) {
        NIMSDK.shared().qchatMessageManager.getMessageHistory(param.toImParam()) { error, result in
            completion(error, result?.messages)
        }
    }
    
    public func markMessageRead(param:MarkMessageReadParam, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().qchatMessageManager.markMessageRead(param.toImParam()) { error in
            completion(error)
        }
    }
    
    public func addDelegate(delegate:NIMQChatMessageManagerDelegate) {
        NIMSDK.shared().qchatMessageManager.add(delegate)
    }
    
    public func removeDelegate(delegate: NIMQChatMessageManagerDelegate) {
        NIMSDK.shared().qchatMessageManager.add(delegate)
    }
  
}
