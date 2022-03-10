//
//  QChatSelectedCell.swift
//  QChatKit-UI
//
//  Created by chenyu on 2022/2/7.
//

import UIKit

class QChatSelectedCell: QChatBaseCell {
    
    var user: UserInfo? {
        didSet {
            if let name = user?.nickName {
                headerView.setTitle(name)
            }
            titleLabel.text  = user?.nickName
            headerView.backgroundColor = user?.color
            if let value = user?.select {
                checkBox.isHighlighted = value
            }
            
        }
    }
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .ne_darkText
        return label
    }()
    
    let headerView: QChatUserHeaderView = {
        let header = QChatUserHeaderView(frame: .zero)
        header.titleLabel.font = DefaultTextFont(14)
        header.titleLabel.textColor = UIColor.white
        header.layer.cornerRadius = 18
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    
    let checkBox: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage.ne_imageNamed(name: "unselect")
        image.highlightedImage = UIImage.ne_imageNamed(name: "select")
        return image
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
        contentView.addSubview(checkBox)
        NSLayoutConstraint.activate([
            checkBox.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            headerView.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 12),
            headerView.widthAnchor.constraint(equalToConstant: 36),
            headerView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo:contentView.leftAnchor, constant: 98),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -35),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setSelect(){
        user?.select = true
        checkBox.isHighlighted = true
    }
    
    func setUnselect(){
        user?.select = false
        checkBox.isHighlighted = false
    }

}
