//
//  FriendProvider.swift
//  ContactKit
//
//  Created by yuanyuan on 2022/1/5.
//

import Foundation
import NIMSDK
public protocol FriendProviderDelegate: AnyObject {
//    Friend relationship changed
    func onFriendChanged(user: User)
    func onUserInfoChanged(user: User)
    func onBlackListChanged()

}

public class FriendProvider: NSObject, NIMUserManagerDelegate {
    public static let shared = FriendProvider()
    private let mutiDelegate = MultiDelegate<FriendProviderDelegate>(strongReferences: false)
    private override init(){
        super.init()
        NIMSDK.shared().userManager.add(self)
    }
    public func addDelegate(delegate:FriendProviderDelegate) {
        mutiDelegate.addDelegate(delegate)
    }
    public func removeDelegate(delegate: FriendProviderDelegate) {
        mutiDelegate.removeDelegate(delegate)
    }
    
    /// Get list of friend
    /// - Returns: List of friend
    public func getMyFriends() -> [User] {
        var friendList: [User] = []
        guard let friends = NIMSDK.shared().userManager.myFriends() else {
            return friendList
        }
        print("[coreKitIM] getMyFriends:\(friends)")
        for friend in friends {
            friendList.append(User(user: friend))
        }
        return friendList
    }
    
    //    get user info from remote
    public func fetchUserInfo(accountList: [String] ,_ completion: @escaping ([User], NSError?)->()) {
        NIMSDK.shared().userManager.fetchUserInfos(accountList) { imUsers, error in
            var users: [User] = []
            print("[coreKitIM] fetchUserInfo:\(imUsers)")
            for imUser in imUsers ?? [] {
                users.append(User(user: imUser))
            }
            completion(users, error as NSError?)
        }
    }
    
//    get user info from local
    public func getUserInfo(userId: String) -> User? {
        let imUser = NIMSDK.shared().userManager.userInfo(userId)
        if imUser != nil {
            return User(user: imUser)
        }
        return nil
    }
    
//    get user info from local first, if return nil, request user info from remote
    public func getUserInfoAdvanced(userIds: [String], _ completion: @escaping ([User], NSError?)->()) {
        var ramainIds = [String]()
        var users = [User]()
        for userId in userIds {
            print("get local user info:\(userId)")
            if let user = self.getUserInfo(userId: userId) {
                users.append(user)
            }else {
                ramainIds.append(userId)
            }
        }
        if !ramainIds.isEmpty {
            print("get remote user info ramainIds:\(ramainIds)")
            self.fetchUserInfo(accountList: ramainIds) { userArray, error in
                print("get remote user info userArray:\(userArray) error:\(error)")
                for u in userArray {
                    users.append(u)
                }
                completion(users, error)
            }
        }else {
            completion(users, nil)
        }
    }
    
    public func addFriend(request: AddFriendRequest,_ completion: @escaping (NSError?)->()) {
        let req = NIMUserRequest()
        req.userId = request.account
        switch request.operationType {
        case .add:
            req.operation = .add
        case .addRequest:
            req.operation = .request
        case .verify:
            req.operation = .verify
        case .reject:
            req.operation = .reject
        }
        req.message = request.meassage
        NIMSDK.shared().userManager.requestFriend(req, completion: { error in
            completion(error as NSError?)
       })
    }
    
    /// deleteFiend
    /// - Parameters:
    ///   - account: account of user
    public func deleteFriend(account: String ,_ completion: @escaping (NSError?)->()) {
        NIMSDK.shared().userManager.deleteFriend(account) { error in
            completion(error as NSError?)
        }
    }
    
    public func isFriend(account: String) -> Bool {
        return NIMSDK.shared().userManager.isMyFriend(account)
    }
    
    /// return Blacklist
    /// - Returns: Blacklist
    public func getBlacklist() -> [User] {
        var blackList: [User] = []
        guard let blacks = NIMSDK.shared().userManager.myBlackList() else {
            print("[coreKitIM] getBlacklist:\(blackList)")
            return blackList
        }
        print("[coreKitIM] getBlacklist:\(blacks)")
        for black in blacks {
            blackList.append(User(user: black))
        }
        return blackList
    }
    
    public func updateUser(_ user: User, _ completion: @escaping (Error?) -> Void){
        let nimUser = NIMUser()
        nimUser.alias = user.alias
        nimUser.userId = user.userId
        NIMSDK.shared().userManager.update(nimUser) { error in
            completion(error)
        }
    }
    
    /// remove from black list
    public func removeFromBlackList(account: String, _ completion: @escaping (NSError?)->()) {
        NIMSDK.shared().userManager.remove(fromBlackBlackList: account) { error in
            print("[coreKitIM] removeFromBlackList error:\(String(describing: error?.localizedDescription))")
            completion(error as NSError?)
        }
    }
    
    /// add black list
    public func addBlackList(account: String, _ completion: @escaping (NSError?)->()) {
        NIMSDK.shared().userManager.add(toBlackList: account) { error in
            print("[coreKitIM] addBlackList error:\(String(describing: error?.localizedDescription))")
            completion(error as NSError?)
        }
    }
    
    /// add black list
    public func isBlack(account: String) -> Bool {
        return NIMSDK.shared().userManager.isUser(inBlackList: account)
    }
        
    
//MARK:NIMUserManagerDelegate
    public func onFriendChanged(_ user: NIMUser) {
        print(#file + #function)
        mutiDelegate |> { delegate in
            delegate.onFriendChanged(user: User(user: user))
        }
    }
    
    public func onBlackListChanged() {
        print(#file + #function + "\(self)")
        mutiDelegate |> { delegate in
            delegate.onBlackListChanged()
        }
    }
    
    public func onUserInfoChanged(_ user: NIMUser) {
        print(#file + #function)
        mutiDelegate |> { delegate in
            delegate.onUserInfoChanged(user: User(user: user))
        }
    }
    

}
