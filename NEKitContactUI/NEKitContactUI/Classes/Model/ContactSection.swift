//
//  ContactSection.swift
//  NEKitContact
//
//  Created by yuanyuan on 2021/12/30.
//

import Foundation
import NEKitContact
import NEKitCoreIM

public class ContactSection {
    public var initial: String
    public var contacts: Array = [ContactInfo]()
    init(initial: String, contacts: [ContactInfo]) {
        self.initial = initial
        self.contacts = contacts
    }
    
}
