//
//  QChatImageTableViewCell.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/2/28.
//

import Foundation
import UIKit
import NIMSDK
class QChatImageTableViewCell: QChatBaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentBtn.addCorner(conrners: .allCorners, radius: 8)
    }
    
    override public var messageFrame:QChatMessageFrame? {
        didSet {
//            contentBtn.setBubbleImage(image: UIImage())
            let imageUrl = messageFrame?.message?.messageObject as! NIMImageObject
            print("set image url : ", imageUrl.url as Any)
            contentBtn.sd_setImage(with: URL.init(string: imageUrl.url ?? ""), for: .normal, completed: nil)
            
            if let _ = imageUrl.url {
                contentBtn.setBubbleImage(image: UIImage())
            }
        }
    }
}
