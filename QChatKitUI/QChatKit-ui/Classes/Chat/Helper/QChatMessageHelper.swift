//
//  QChatMessageHelper.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/3/2.
//

import Foundation

class QChatMessageHelper {
    //获取图片合适尺寸
    class func getSizeWithMaxSize(_ maxSize: CGSize, size: CGSize,miniWH:CGFloat) -> CGSize {
        
        var realSize = CGSize.zero
        
        if min(size.width, size.height) > 0 {
            if size.width > size.height {
                //宽大 按照宽给高
                let width = CGFloat(min(maxSize.width, size.width))
                realSize = CGSize(width: width, height: width * size.height / size.width)
                if realSize.height < miniWH {
                    realSize.height = miniWH
                }
            } else {
                //高大 按照高给宽
                let height = CGFloat(min(maxSize.height, size.height))
                realSize = CGSize(width: height * size.width / size.height, height: height)
                if realSize.width < miniWH {
                    realSize.width = miniWH
                }
            }
        }else {
            realSize = maxSize
        }
        
        return realSize
    }
}
