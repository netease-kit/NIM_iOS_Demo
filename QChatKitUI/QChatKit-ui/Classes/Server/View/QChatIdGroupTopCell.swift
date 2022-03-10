//
//  QChatIdGroupTopCell.swift
//  QChatKit-UI
//
//  Created by yu chen on 2022/1/25.
//

import UIKit

class QChatIdGroupTopCell: QChatIdGroupCell {

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
        leftSpace?.constant = 20.0
        headImage.image = UIImage.ne_imageNamed(name: "member_header")
        titleLeftSpace?.constant = 12.0
        countHeadWidth?.constant = 0
        countHeadImage.isHidden = true
        headWidth?.constant = 36.0
        headHeight?.constant = 36.0
    }

}
