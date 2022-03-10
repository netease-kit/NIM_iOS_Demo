//
//  ContactInfo.swift
//  ContactKit-UI
//
//  Created by chenyu on 2022/1/11.
//

import Foundation
import CoreKit_IM
import UIKit

public class ContactInfo {
    /*
    func getName() -> String {
        if let alias = user?.alias {
            return alias
        }
        if let nickName = user?.userInfo?.nickName {
            return nickName
        }
        return "#"
    }*/
    
    func getRowHeight() -> CGFloat? {
        return nil
    }
    public var user: User?
    public var contactCellType = ContactCellType.ContactPerson.rawValue
    public var router = ContactPersonRouter
    public var isSelected = false
    public var headerBackColor: UIColor?
}
