//
//  XString.swift
//  ContactKit
//
//  Created by yuanyuan on 2021/12/30.
//

import Foundation
extension String {
    
    /// Inital of string, return "#" if the initials are not within A - Z
    /// - Returns: Inital Letter of string
    public func initalLetter() -> String? {
        if self.isEmpty {
            return nil
        }
        if isChinese() {
            let string = self.transformToLatin()
            let ch = string[string.startIndex]
            return String(ch).uppercased()
        }else {
            let ch = self[self.startIndex]
            return String(ch).uppercased()
        }
    }
    
    func isChinese() -> Bool {
            for ch in self.unicodeScalars {
                // Chinese：0x4e00 ~ 0x9fff
                if (0x4e00 < ch.value && ch.value < 0x9fff) {
                    return true
                }
            }
            return false
        }

    func transformToLatin() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false);
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false);
        let string = stringRef as String
        return string.trimmingCharacters(in: .whitespaces)
    }
    
    
    public var isBlank:Bool{
        /// 字符串中的所有字符都符合block中的条件，则返回true
        let _blank = self.allSatisfy{
            let _blank = $0.isWhitespace
            print("字符：\($0) \(_blank)")
            return _blank
        }
        return _blank
    }
    ///通过裁剪字符串中的空格和换行符，将得到的结过进行isEmpty
    var isReBlank:Bool{
        let str = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return str.isEmpty
    }
    
    
}
