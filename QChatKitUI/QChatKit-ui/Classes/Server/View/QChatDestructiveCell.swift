//
//  QChatDestructiveCell.swift
//  Pods
//
//  Created by yu chen on 2022/1/24.
//

import UIKit

class QChatDestructiveCell: QChatCornerCell {
    
    lazy var redTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ne_redText
        label.font = DefaultTextFont(16)
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
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.addSubview(redTextLabel)
        NSLayoutConstraint.activate([
            redTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            redTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func changeDisableTextColor(){
        redTextLabel.textColor = .ne_disableRedText
    }
    
    func changeEnableTextColor(){
        redTextLabel.textColor = .ne_redText
    }

}
