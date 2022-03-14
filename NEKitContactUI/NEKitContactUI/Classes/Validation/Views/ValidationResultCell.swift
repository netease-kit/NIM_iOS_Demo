//
//  ValidationResultCell.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/19.
//

import UIKit

class ValidationResultCell: BaseValidationCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            resultLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            resultLabel.widthAnchor.constraint(equalToConstant: 48)
        ])
        
        let rightImage = UIImageView()
        contentView.addSubview(rightImage)
        rightImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightImage.leftAnchor.constraint(equalTo: resultLabel.rightAnchor, constant: 0),
            rightImage.centerYAnchor.constraint(equalTo: resultLabel.centerYAnchor),
            rightImage.widthAnchor.constraint(equalToConstant: 16),
            rightImage.heightAnchor.constraint(equalToConstant: 16)
        ])
        rightImage.image = UIImage.ne_imageNamed(name: "finishFlag")
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightImage.leftAnchor, constant: -16)
        ])
    }

}
