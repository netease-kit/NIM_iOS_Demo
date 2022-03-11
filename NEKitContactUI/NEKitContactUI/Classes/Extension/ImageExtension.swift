//
//  ImageExtension.swift
//  NEKitContactUI
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
//        guard let path = Bundle(for: ContactsViewController.self).resourcePath?.appending("/ContactKit_UIBundle.bundle") else {
//            print("Image:\(imageName) path: nil")
//            return nil
//        }
//        var bundle = Bundle(path: path)
//        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
}
