//
//  ContactViewModel.swift
//  NEKitContact
//
//  Created by yuanyuan on 2021/12/31.
//

import Foundation
import NEKitContact
import NEKitCoreIM
import UIKit

public class ContactViewModel: ContactRepoSystemNotiDelegate {
    
    typealias RefreshBlock = () -> Void
    public var contacts: [ContactSection] = []
    public var indexs: [String]?
    private var contactHeaders: [ContactHeadItem]?
    public var contactRepo = ContactRepo()
    private var initalDict: [String: [ContactInfo]] = ["#":[]]
    
    var unreadCount = 0
    
    var refresh: RefreshBlock?
    init(contactHeaders: [ContactHeadItem]?) {
        contactRepo.notiDelegate = self
        unreadCount = contactRepo.getUnreadCount()
        self.contactHeaders = contactHeaders
    }
    
    public func onNotificationUnreadCountChanged(_ count: Int) {
        print("onNotificationUnreadCountChanged : ", count)
        unreadCount = count
        if let block = refresh {
            block()
        }
    }
    
    public func onRecieveNotification(_ notification: XNotification) {
        
    }
    
    func loadData()  {
        initalDict = ["#":[]]
        contacts = getContactList()
        indexs = getIndexs(contactSections: contacts)
        guard let headSection = headerSection(headerItem: self.contactHeaders) else {
            return
        }
        contacts.insert(headSection, at: 0)
    }
    
    func getContactList() -> [ContactSection] {
        var contactList: [ContactSection] = []
        let Users = contactRepo.getFriends()
        if Users.isEmpty {
            return contactList
        }
        for contact: User in Users {
            // get inital of name
            var name = contact.alias != nil ? contact.alias : contact.userInfo?.nickName
            if name == nil {
                name = contact.userId
            }
            let inital = name?.initalLetter()
            let contactInfo = ContactInfo()
            contactInfo.user = contact
            contactInfo.headerBackColor = UIColor.colorWithString(string: contact.userId)

            var contactsTemp = initalDict[inital!]
            if contactsTemp == nil {
                contactsTemp = [contactInfo]
                initalDict[inital!] = contactsTemp
            }else {
                initalDict[inital!]?.append(contactInfo)
            }
        }
        
        for key in initalDict.keys {
            contactList.append(ContactSection(initial: key, contacts: initalDict[key]!))
        }
        
        // sort by inital
        return contactList.sorted { s1, s2 in
            return s1.initial < s2.initial
        }
    }
    
    func headerSection(headerItem: [ContactHeadItem]?) -> ContactSection? {
        guard let header = headerItem else {
            return nil
        }
        var infos: [ContactInfo] = []
        for item in header {
            var user = User()
            user.alias = item.name
            user.imageName = item.imageName
            let info = ContactInfo()
            info.user = user
            info.contactCellType = ContactCellType.ContactOthers.rawValue
            info.router = item.router
            info.headerBackColor = UIColor.colorWithString(string: user.userId)
            infos.append(info)
        }
        return ContactSection(initial: "", contacts: infos)
    }
    
    func getIndexs(contactSections: [ContactSection]?) -> [String]? {
        guard let sections = contactSections else {
            return nil
        }
        var indexs: [String] = []
        for section in sections {
            if section.initial.count > 0 {
                indexs.append(section.initial)
            }
        }
        return indexs
    }
    

}
