//
//  ContactUserViewModel.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/14.
//

import Foundation
import NEKitContact
import NEKitCoreIM
class ContactUserViewModel {
    
    let contactRepo = ContactRepo()

    func addFriend(_ account: String, _ completion: @escaping (NSError?)->()){
        print("account : ", account)
        let request = AddFriendRequest()
        request.account = account
        request.operationType = .add
        contactRepo.addFriend(request: request, completion)
    }
    
    public func deleteFriend(account: String ,_ completion: @escaping (NSError?)->()) {
        return contactRepo.deleteFriend(account: account, completion)
    }

    public func isFriend(account: String) -> Bool {
        return contactRepo.isFriend(account: account)
    }
    
    public func isBlack(account: String) -> Bool {
        return contactRepo.isBlack(account: account)
    }
    
    public func update(_ user: User, _ completion: @escaping (Error?) -> Void){
        contactRepo.updateUser(user, completion)
    }
    
}
