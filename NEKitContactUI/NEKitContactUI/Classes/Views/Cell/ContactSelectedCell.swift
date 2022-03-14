//
//  ContactSelectedCell.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/17.
//

import UIKit

class ContactSelectedCell: ContactTableViewCell {
    
    let sImage = UIImageView()
    
    var sModel: ContactInfo?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func commonUI() {
        super.commonUI()
        leftConstraint?.constant = 50
        contentView.addSubview(sImage)
        sImage.image = UIImage.ne_imageNamed(name: "unselect")
        sImage.highlightedImage = UIImage.ne_imageNamed(name: "select")
        sImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20)
        ])
    }
    
    override func setModel(_ model: ContactInfo, _ config: ContactsConfig) {
        super.setModel(model, config)
        if model.isSelected == false {
            sImage.isHighlighted = false
        }else {
            sImage.isHighlighted = true
        }
    }
    
    func setSelect(){
        sModel?.isSelected = true
        sImage.isHighlighted = true
    }
    
    func setUnselect(){
        sModel?.isSelected = false
        sImage.isHighlighted = false
    }

}
