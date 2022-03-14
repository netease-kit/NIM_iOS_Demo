//
//  QChatMemberManagerCell.swift
//  NEKitQChatUI
//
//  Created by yu chen on 2022/2/8.
//

import UIKit

class QChatMemberManagerCell: QChatIdGroupMemberCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setupUI() {
        super.setupUI()
        contentView.backgroundColor = .white
        leftSpace?.constant = 20
        rightSpace?.constant = -20
    }

}
