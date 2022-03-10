//
//  TextWithRightArrowCell.swift
//  ContactKit-UI
//
//  Created by yuanyuan on 2022/1/18.
//

import UIKit

class TextWithRightArrowCell: TextBaseCell {
    public var arrowImage = UIImageView(image: UIImage.ne_imageNamed(name: "arrowRight"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.arrowImage.translatesAutoresizingMaskIntoConstraints = false
        self.arrowImage.contentMode = .center
        self.contentView.addSubview(self.arrowImage)
        NSLayoutConstraint.activate([
            self.arrowImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20),
            self.arrowImage.widthAnchor.constraint(equalToConstant: 20),
            self.arrowImage.heightAnchor.constraint(equalToConstant: 20),
            self.arrowImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setModel(model: UserItem) {
        super.setModel(model: model)
//        self.detailTitleLabel.text = model.detailTitle
    }
}
