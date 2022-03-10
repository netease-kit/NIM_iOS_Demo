//
//  CoreKitIMEngine.swift
//  CoreKit-IM
//
//  Created by yu chen on 2021/12/30.
//

import Foundation
import NIMSDK
import UIKit

public class CoreKitIMEngine {
    
    public static let instance = CoreKitIMEngine()
    public func setupCoreKitIM(_ option: NIMSDKOption) {
        NIMSDK.shared().register(with: option)
    }
    //保存登录信息
    public var imAccid:String = ""
    public var imToken:String = ""

    public func loginIM(_ account: String, _ token: String, _ block: @escaping (Error?)->()){
        self.imAccid = account
        self.imToken = token
        NIMSDK.shared().loginManager.login(account, token: token) { error in
            if let err = error {
                block(err)
            }else {
                block(nil)
            }
        }
    }
    
    public func isMySelf(_ accid: String?) -> Bool {
        if let aid = accid, aid == imAccid{
            return true
        }
        return false
    }
    
    /// 圈组登录接口
    /// - Parameters:
    ///   - loginParam: 登录参数
    ///   - completion: 返回结果
    public func loginQchat(_ loginParam: QChatLoginParam,completion: @escaping (Error?,QChatLoginResult?)->()){
        NIMSDK.shared().qchatManager.login(loginParam.toIMParam()) { error, result in
            if let err = error {
                completion(err,nil)
            }else {
                completion(nil,QChatLoginResult(loginResult: result))
            }
        }
    }

}

