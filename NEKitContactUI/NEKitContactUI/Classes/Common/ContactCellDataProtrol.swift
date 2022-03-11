//
//  ContactCellDataProtrol.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/12.
//

import Foundation
import UIKit

public protocol ContactCellDataProtrol {
    func setModel(_ model: ContactInfo, _ config: ContactsConfig)
}
