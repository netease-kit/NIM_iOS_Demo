//
//  File.swift
//  CoreKit
//
//  Created by yuanyuan on 2022/1/5.
//

import Foundation
import NIMSDK

public enum Gender {
    case unknown
    case male
    case female
}

public struct UserInfo {
    public var nickName: String?
    public var avatarUrl: String?
    public var thumbAvatarUrl: String?
    public var sign: String?
    public var gender: Gender?
    public var email: String?
    public var birth: String?
    public var mobile: String?
    public var ext: String?
    
    init(userInfo: NIMUserInfo?) {
        self.nickName = userInfo?.nickName
        self.avatarUrl = userInfo?.avatarUrl
        self.thumbAvatarUrl = userInfo?.thumbAvatarUrl
        self.sign = userInfo?.sign
        switch userInfo?.gender {
        case .male:
            self.gender = .male
        case .female:
            self.gender = .female
        default:
            self.gender = .unknown
        }
        self.email = userInfo?.email
        self.birth = userInfo?.birth
        self.mobile = userInfo?.mobile
        self.ext = userInfo?.ext
    }
    
    func toImUser() -> NIMUserInfo {
        let nimUser = NIMUserInfo()
        return nimUser
    }
}
