//
//  XLocalize.swift
//  CoreKit
//
//  Created by yu chen on 2022/1/21.
//

import Foundation

public class CoreLoader<T: AnyObject> {
    
    let bundle = Bundle(for: T.self)
    
    public init(){}
    public func localizable(_ key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
//        print("localizable value : ", value)
        return value
    }
    
    public func loadImage(_ name: String) -> UIImage? {
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
}
