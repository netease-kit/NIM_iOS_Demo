//
//  QChatSortCell.swift
//  NEKitQChatUI
//
//  Created by chenyu on 2022/2/6.
//

import UIKit

class QChatSortCell: QChatIdGroupCell {
    
    lazy var dotImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage.ne_imageNamed(name: "dot_image")
        image.highlightedImage = UIImage.ne_imageNamed(name: "dot_image_disable")
        return image
    }()

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
//        self.leftSpace?.constant = 72
        tailImage.image = UIImage.ne_imageNamed(name: "delete")
        tailImage.highlightedImage = UIImage.ne_imageNamed(name: "lock")
//        contentView.addSubview(dotImage)
//        NSLayoutConstraint.activate([
//            dotImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 31),
//            dotImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
        
    }

}
