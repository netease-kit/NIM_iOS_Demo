//
//  CoreKitEngine.swift
//  CoreKit
//
//  Created by yu chen on 2021/12/30.
//

import Foundation
import CoreKit_IM
import NIMSDK
public class CoreKitEngine {
    public static let instance = CoreKitEngine()
    public func setupCoreKit(_ option: NIMSDKOption) {
        CoreKitIMEngine.instance.setupCoreKitIM(option)
        //和头像上传速度相关配置
        NIMSDKConfig.shared().fcsEnable = false
        //log日志配置
        QChatLog.setUp()
    }
    //保存登录信息
    public var imAccid:String = ""
    public var imToken:String = ""

    public func login(_ account: String, _ token: String, _ completion: @escaping (Error?)->() ){
        self.imAccid = account
        self.imToken = token
        CoreKitIMEngine.instance.loginIM(account, token, completion)
    }
}
