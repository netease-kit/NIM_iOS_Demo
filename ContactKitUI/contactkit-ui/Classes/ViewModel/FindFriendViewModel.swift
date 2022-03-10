//
//  FindFriendViewModel.swift
//  ContactKit-UI
//
//  Created by yu chen on 2022/1/13.
//

import Foundation
import ContactKit
import CoreKit_IM

class FindFriendViewModel {
    
    let contactRepo = ContactRepo()
    
    func searchFriend(_ text: String, _ completion: @escaping ([User]?, NSError?)->()){
        contactRepo.fetchUserInfo(accountList: [text], completion)
    }
    
}
