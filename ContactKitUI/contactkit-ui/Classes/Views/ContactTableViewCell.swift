//
//  ContactTableViewCell.swift
//  ContactKit-UI
//
//  Created by yuanyuan on 2022/1/6.
//

import UIKit
import CoreKit_IM
import Foundation
import CoreKit

public class ContactTableViewCell: ContactBaseViewCell, ContactCellDataProtrol {
    
    weak var uiConfig: ContactsConfig?
    
    public lazy var arrow: UIImageView = {
        let imageView = UIImageView(image:UIImage.ne_imageNamed(name: "arrowRight"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    lazy var redAngleView: RedAngleLabel = {
        let label = RedAngleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .white
        label.text = "1"
        label.backgroundColor = UIColor(hexString: "F24957")
        label.textInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        
        //circle avatar head image with name suffix string
        setupCommonCircleHeader()
        
        self.contentView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.avatarImage.rightAnchor, constant: 12),
            self.titleLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -35),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        self.contentView.addSubview(self.arrow)
        NSLayoutConstraint.activate([
            self.arrow.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20),
            self.arrow.widthAnchor.constraint(equalToConstant: 15),
            self.arrow.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.arrow.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        contentView.addSubview(redAngleView)
        NSLayoutConstraint.activate([
            redAngleView.centerYAnchor.constraint(equalTo: arrow.centerYAnchor),
            redAngleView.rightAnchor.constraint(equalTo: arrow.leftAnchor, constant: -10)
        ])
    }
    
    func setConfig(_ config: ContactsConfig){
        self.titleLabel.font = config.cellTitleFont
        self.titleLabel.textColor = config.cellTitleColor
        self.nameLabel.font = config.cellNameFont
        self.nameLabel.textColor = config.cellNameColor
    }
    
    public func setModel(_ model: ContactInfo, _ config: ContactsConfig) {
        guard let user = model.user else {
            return
        }
        if uiConfig == nil {
            uiConfig = config
            setConfig(config)
        }

        // avatar
        self.avatarImage.image = UIImage.ne_imageNamed(name: user.imageName)
        
        // title
        var showName = user.alias?.count ?? 0 > 0 ? user.alias : user.userInfo?.nickName

        if showName?.count ?? 0 <= 0 {
            showName = user.userId
        }
        
        guard let name = showName else {
            return
        }
        
        self.titleLabel.text = name
        if self.avatarImage.image == nil {
            self.arrow.isHidden = true
            showNameOnCircleHeader(name)
            
        }else {
            self.arrow.isHidden = false
            showNameOnCircleHeader("")
        }
        self.arrow.isHidden = model.contactCellType != 1
        
        if let color = model.headerBackColor {
            avatarImage.backgroundColor = color
        }
    }
}
