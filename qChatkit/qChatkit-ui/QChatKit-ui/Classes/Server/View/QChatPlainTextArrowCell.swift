//
//  QChatPlainTextArrowCell.swift
//  QChatKit-UI
//
//  Created by yu chen on 2022/2/8.
//

import UIKit

class QChatPlainTextArrowCell: QChatTextArrowCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        setupUI()
    }
    
    func setupUI(){
        contentView.backgroundColor = .white
        titleLeftMargin?.constant = 20
        detailRightMargin?.constant = -42
        rightImageMargin?.constant = -20
    }

}
