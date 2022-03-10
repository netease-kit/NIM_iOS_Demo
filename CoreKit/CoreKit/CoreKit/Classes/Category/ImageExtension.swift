//
//  ImageExtension.swift
//  ContactKit-UI
//
//  Created by yuanyuan on 2022/1/6.
//

import Foundation
extension UIImage {
    public class func ne_imageNamed(name: String?) -> UIImage? {
        guard let imageName = name else {
            return nil
        }
        return coreLoader.loadImage(imageName)
//        guard let path = Bundle(for: NEBaseViewController.self).resourcePath?.appending("/CoreKitBundle.bundle") else {
//            print("Image:\(imageName) path: nil")
//            return nil
//        }
//        return UIImage(named: imageName, in: Bundle(path: path), compatibleWith: nil)
    }
}
