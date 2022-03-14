//
//  QChatIdGroupSelectCell.swift
//  NEKitQChatUI
//
//  Created by chenyu on 2022/2/4.
//

import UIKit

class QChatIdGroupSelectCell: QChatCornerCell {
    
    var group: IdGroupModel? {
        didSet {
            if let select = group?.isSelect {
                tailImage.isHighlighted = select
            }
            nameLabel.text = group?.idName
            if let type = group?.cornerType {
                cornerType = type
            }
        }
    }
    
    let tailImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.ne_imageNamed(name: "unselect")
        image.highlightedImage = UIImage.ne_imageNamed(name: "select")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ne_darkText
        label.font = DefaultTextFont(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        contentView.addSubview(tailImage)
        NSLayoutConstraint.activate([
            tailImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -36),
            tailImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 36),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(36 + 23)),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }

}
