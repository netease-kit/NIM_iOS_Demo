//
//  ContactSection.swift
//  ContactKit
//
//  Created by yuanyuan on 2021/12/30.
//

import Foundation
import ContactKit
import CoreKit_IM

public class ContactSection {
    public var initial: String
    public var contacts: Array = [ContactInfo]()
    init(initial: String, contacts: [ContactInfo]) {
        self.initial = initial
        self.contacts = contacts
    }
    
}
