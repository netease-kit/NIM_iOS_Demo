//
//  QChatHeaderCell.swift
//  QChatKit-UI
//
//  Created by chenyu on 2022/2/4.
//

import UIKit

class QChatHeaderCell: QChatCornerCell {
    
    var user: UserInfo? {
        didSet {
            if let name = user?.nickName {
                headerView.setTitle(name)
                nameLabel.text = name
            }else if let aid = user?.accid {
                headerView.setTitle(aid)
                nameLabel.text = aid
            }
            headerView.backgroundColor = user?.color
        }
    }
    
    let headerView: QChatUserHeaderView = {
        let header = QChatUserHeaderView(frame: .zero)
        header.titleLabel.font = DefaultTextFont(20)
        header.titleLabel.textColor = UIColor.white
        header.layer.cornerRadius = 30
        header.translatesAutoresizingMaskIntoConstraints = false
//        header.backgroundColor = UIColor.randomColor()
        
        return header
    }()
    
    let nameLabel: UILabel = {
        let label  = UILabel()
        label.textColor = .ne_darkText
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
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 36),
            headerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            headerView.widthAnchor.constraint(equalToConstant: 60),
            headerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: headerView.rightAnchor, constant: 16),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -36),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

}
