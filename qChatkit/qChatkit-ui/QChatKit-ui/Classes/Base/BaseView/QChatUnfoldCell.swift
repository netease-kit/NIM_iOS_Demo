//
//  QChatUnfoldCell.swift
//  QChatKit-UI
//
//  Created by chenyu on 2022/2/1.
//

import UIKit

class QChatUnfoldCell: QChatCornerCell {
    
    lazy var arrowImage: UIImageView = {
        let arrow = UIImageView()
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.image = UIImage.ne_imageNamed(name: "arrowDown")
        return arrow
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ne_greyText
        label.font = DefaultTextFont(14)
        return label
    }()

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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupUI(){
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(arrowImage)
        NSLayoutConstraint.activate([
            arrowImage.leftAnchor.constraint(equalTo: contentLabel.rightAnchor, constant: 5),
            arrowImage.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor)
        ])
    }
    
    func changeToArrowUp(){
        arrowImage.image = UIImage.ne_imageNamed(name: "arrowUp")
    }
    
    func changeToArrowDown(){
        arrowImage.image = UIImage.ne_imageNamed(name: "arrowDown")
    }

}
