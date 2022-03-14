//
//  QChatSectionView.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/1/24.
//

import UIKit

class QChatSectionView: UITableViewHeaderFooterView {
    public var titleLable = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        self.contentView.backgroundColor = .ne_lightBackgroundColor
        self.titleLable.font = UIFont.systemFont(ofSize: 12)
        self.titleLable.textColor = .ne_greyText
        self.titleLable.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.titleLable)
        NSLayoutConstraint.activate([
            self.titleLable.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 33),
            self.titleLable.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.titleLable.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.titleLable.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -33)
        ])
        
    }


}
