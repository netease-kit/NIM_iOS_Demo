//
//  UIColorExtension.swift
//  ContactKit-UI
//
//  Created by yu chen on 2022/1/13.
//

import Foundation

public extension UIColor {
    
    // Hex String -> UIColor
    convenience init(hexString: String, _ alpha: CGFloat = 1.0) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
         
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
         // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
//    class func randomColor() -> UIColor {
//        let red = CGFloat(arc4random()%256)/255.0
//        let green = CGFloat(arc4random()%256)/255.0
//        let blue = CGFloat(arc4random()%256)/255.0
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//    }
    public class func colorWithNumber(number: UInt64?) -> UIColor {
        let mod = (number ?? 0) % 7
//        print("mod:\(mod)")
        switch mod {
        case 0:
            return UIColor(hexString: "#60CFA7")
        case 1:
            return UIColor(hexString: "#53C3F3")
        case 2:
            return UIColor(hexString: "#537FF4")
        case 3:
            return UIColor(hexString: "#854FE2")
        case 4:
            return UIColor(hexString: "#BE65D9")
        case 5:
            return UIColor(hexString: "#E9749D")
        case 6:
            return UIColor(hexString: "#F9B751")
        default:
            return UIColor(hexString: "#60CFA7")
        }
    }
    
    public class func colorWithString(string: String?) -> UIColor {
        return colorWithNumber(number: UInt64(string?.last?.asciiValue ?? 0))
    }
        
}
