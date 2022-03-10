//
//  Constants.swift
//  CoreKit
//
//  Created by yu chen on 2022/1/22.
//

import Foundation

let coreLoader = CoreLoader<NEBaseViewController>()
func localizable(_ key: String) -> String{
    return coreLoader.localizable(key)
}

