//
//  ValidationMessageViewModel.swift
//  ContactKit-UI
//
//  Created by yu chen on 2022/1/14.
//

import Foundation
import ContactKit
import CoreKit_IM

public class ValidationMessageViewModel: ContactRepoSystemNotiDelegate {
    
    typealias DataRefresh = () -> Void
    
    var dataRefresh: DataRefresh?
    
    let contactRepo = ContactRepo()
    var datas = [XNotification]()
    
    init(){
        contactRepo.notiDelegate = self
    }
    
    public func onNotificationUnreadCountChanged(_ count: Int) {
        
    }
    
    public func onRecieveNotification(_ notification: XNotification) {
        if notification.type == .addFriendDirectly {
            datas.insert(notification, at: 0)
        }
        contactRepo.clearUnreadCount()
        if let block = dataRefresh {
            block()
        }
    }
    
    func getValidationMessage(_ completin: () -> Void ){
        let data = contactRepo.getNotificationList(limit: 500)
        print("get validation message : ", data)
        data.forEach { noti in
            if noti.type == .addFriendDirectly {
                datas.append(noti)
            }
            print("get noti : ", noti.type as Any)
        }
        if datas.count > 0 {
            completin()
        }
    }
    
    func clearAllNoti(_ completion: () -> Void){
        contactRepo.deleteNoti()
        datas.removeAll()
        completion()
    }
    
}
