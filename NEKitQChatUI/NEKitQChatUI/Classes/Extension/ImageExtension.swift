//
//  ImageExtension.swift
//  NEKitContactUI
//
//  Created by yuanyuan on 2022/1/6.
//

import Foundation
import CoreGraphics
import UIKit
extension UIImage {
    public class func ne_imageNamed(name: String?) -> UIImage? {
        guard let imageName = name else {
            return nil
        }
        return coreLoader.loadImage(imageName)
//        guard let path = Bundle(for: QChatBaseCell.self).resourcePath?.appending("/NEKitQChatUI.bundle") else {
//            print("Image:\(imageName) path: nil")
//            return nil
//        }
//        let image = UIImage(named: imageName, in: Bundle(path: path), compatibleWith: nil)
//        print("Bundle:\(Bundle(path: path))")
//        print("imageName:\(imageName) image:\(image)")
//        return image
    }
    

}
