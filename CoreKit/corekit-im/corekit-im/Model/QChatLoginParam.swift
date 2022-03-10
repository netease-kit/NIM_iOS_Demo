//
//  QChatLoginParam.swift
//  CoreKit-IM
//
//  Created by vvj on 2022/1/25.
//

import Foundation
import NIMSDK

public enum LoginAuthType:Int{
    case theDefault = 0
    case dynamicToken = 1
}
public typealias CallBack = (_ str:String)->String

public struct QChatLoginParam {
    public var account: String?
    public var token: String?
    public var authType: LoginAuthType?
    public var dynamicTokenHandler:CallBack?
    public var loginExt: String?
    
   public init(_ account: String, _ token: String) {
        self.account = account
        self.token = token
    }
    
    func toIMParam() -> NIMQChatLoginParam {
        let imParam = NIMQChatLoginParam()

        imParam.dynamicTokenHandler = {(account) -> String in
            guard let token = self.token else {
                return ""
            }
            return token
        }
        switch self.authType {
        case .dynamicToken:
            imParam.authType = .dynamicToken
        default:
            imParam.authType = .default
        }
        
//        imParam.loginExt = self.loginExt
        return imParam
    }
}
