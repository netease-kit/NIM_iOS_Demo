//
//  QChatTextArrowCell.swift
//  QChatKit-UI
//
//  Created by yuanyuan on 2022/1/22.
//
//this cell not only has rounding corner style,but has Text、line and arrow with right direction subview

import UIKit

class QChatTextArrowCell: QChatTextCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.rightStyle = .indicate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
