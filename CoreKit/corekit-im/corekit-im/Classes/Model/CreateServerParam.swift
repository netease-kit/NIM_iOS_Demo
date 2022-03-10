//
//  CreateServerParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/2/8.
//

import Foundation
import NIMSDK

//邀请模式
public enum QChatServerInviteMode {
    case needApprove//需要同意
    case autoEnter //不需要同意
}
//申请模式
public enum QChatServerApplyMode{
    case autoEnter//不需要同意
    case needApprove//需要同意
}

public struct CreateServerParam {
    
    //名称，必填
    public var name:String?
    
    public var icon:String?

    public var custom:String?
    //邀请模式
    public var inviteMode:QChatServerInviteMode = .autoEnter
    //申请模式
    public var applyMode:QChatServerApplyMode?

    public init(name:String,icon:String) {
        self.name = name
        self.icon = icon
    }

    func toIMParam() ->  NIMQChatCreateServerParam{
        
        let imParam = NIMQChatCreateServerParam()
        imParam.name = self.name
        imParam.icon = self.icon
        imParam.custom = self.custom
        switch self.inviteMode {
        case .autoEnter:
            imParam.inviteMode = NIMQChatServerInviteMode.autoEnter
        default:
            imParam.inviteMode = NIMQChatServerInviteMode.needApprove
        }
        
        switch self.applyMode {
        case .needApprove:
            imParam.applyMode = NIMQChatServerApplyMode.needApprove
        default:
            imParam.applyMode = NIMQChatServerApplyMode.autoEnter
        }
        return imParam
    }
    
    func toIMUpdateParam() ->  NIMQChatUpdateServerParam{
        let imParam = NIMQChatUpdateServerParam()
        imParam.name = self.name
        imParam.icon = self.icon
        imParam.custom = self.custom
        switch self.inviteMode {
        case .autoEnter:
            imParam.inviteMode = 1
        default:
            imParam.inviteMode = 0
        }
        
        switch self.applyMode {
        case .needApprove:
            imParam.applyMode = 1
        default:
            imParam.applyMode = 0
        }
        return imParam
    }
    
    
}
