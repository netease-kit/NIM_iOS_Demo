//
//  TeamListViewModel.swift
//  NEKitCoreIM
//
//  Created by yuanyuan on 2022/1/13.
//

import Foundation
import NEKitContact
import NEKitCoreIM

public class BlackListViewModel: FriendProviderDelegate {
    var contactRepo = ContactRepo()
    init(){
        contactRepo.addContactDelegate(delegate: self)
    }
    func getBlackList() -> [User]? {
        return contactRepo.getBlackList()
    }
    
    func removeFromBlackList(account: String, _ completion: @escaping (NSError?)->()) {
        contactRepo.removeFromBlackList(account: account, completion)
    }
    
    func addBlackList(account: String, _ completion: @escaping (NSError?)->()) {
        contactRepo.addBlackList(account: account, completion)
    }
    
//MARK: callback
    public func onFriendChanged(user: User) {
        print(#file + #function )
    }
    
    public func onUserInfoChanged(user: User) {
        print(#file + #function)
    }
    
    public func onBlackListChanged() {
        print(#file + #function)
    }
    
    public func onRecieveNotification(notification: XNotification) {
        print(#file + #function)
    }
    
    public func onNotificationUnreadCountChanged(count: Int) {
        print(#file + #function)
    }
}
