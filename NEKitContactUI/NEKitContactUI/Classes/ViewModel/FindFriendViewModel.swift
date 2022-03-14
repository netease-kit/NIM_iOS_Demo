//
//  FindFriendViewModel.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/13.
//

import Foundation
import NEKitContact
import NEKitCoreIM

class FindFriendViewModel {
    
    let contactRepo = ContactRepo()
    
    func searchFriend(_ text: String, _ completion: @escaping ([User]?, NSError?)->()){
        contactRepo.fetchUserInfo(accountList: [text], completion)
    }
    
}
