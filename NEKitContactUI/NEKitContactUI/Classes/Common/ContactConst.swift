//
//  ContactConst.swift
//  NEKitContactUI
//
//  Created by chenyu on 2022/1/11.
//

import Foundation
import CoreText
import NEKitCore


public enum ContactCellType: Int {
    case ContactOthers = 1  // blacklist groups computer and so on
    case ContactPerson = 2  // contact person
    case ContactCutom  = 50 // custom type start with 50
}

public typealias ConttactClickCallBack = (_ index: Int, _ section: Int?) -> Void // parameter type contain ContactCellType and custom type

public typealias ContactsSelectCompletion = ([ContactInfo])->()?


let coreLoader = CoreLoader<ContactBaseViewController>()
func localizable(_ key: String) -> String{
    return coreLoader.localizable(key)
}


