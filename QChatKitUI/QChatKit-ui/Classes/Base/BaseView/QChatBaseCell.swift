//
//  QChatBaseCell.swift
//  QChatKit-UI
//
//  Created by yu chen on 2022/1/22.
//

import UIKit

class QChatBaseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   

}
