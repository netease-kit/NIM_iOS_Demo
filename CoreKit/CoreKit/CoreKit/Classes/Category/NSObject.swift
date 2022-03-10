//
//  NSObject.swift
//  CoreKit
//
//  Created by yu chen on 2022/3/9.
//

import Foundation

public extension NSObject {
    
    func className() -> String {
        if let name = object_getClass(self) {
            let className = String(describing: name)
            return className
        }
        return "unknow class"
    }
}
