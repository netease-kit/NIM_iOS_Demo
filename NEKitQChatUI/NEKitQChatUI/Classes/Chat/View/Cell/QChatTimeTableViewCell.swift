//
//  QChatTimeTableViewCell.swift
//  NEKitQChatUI
//
//  Created by vvj on 2022/3/1.
//

import UIKit

class QChatTimeTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(timeLable)
        NSLayoutConstraint.activate([
            timeLable.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            timeLable.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            timeLable.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            timeLable.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var messageFrame:QChatMessageFrame? {
        didSet {
            timeLable.text = messageFrame?.time
        }
    }

    private lazy var timeLable:UILabel = {
        let label = UILabel()
        label.font = DefaultTextFont(12)
        label.textColor = UIColor.ne_emptyTitleColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
}
