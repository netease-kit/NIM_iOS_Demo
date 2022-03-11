//
//  InviteValidationCell.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/19.
//

import UIKit
import NEKitCore
class InviteValidationCell: BaseValidationCell {
    
    var rejectBtn: ExpandButton = {
        let button = ExpandButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("拒绝", for: .normal)
        button.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.clipsToBounds = false
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    var agreeBtn: ExpandButton = {
        let button = ExpandButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("同意", for: .normal)
        let blue = UIColor(hexString: "337EFF")
        button.setTitleColor(blue, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = blue.cgColor
        return button
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(agreeBtn)
        NSLayoutConstraint.activate([
            agreeBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            agreeBtn.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            agreeBtn.widthAnchor.constraint(equalToConstant: 60),
            agreeBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
        agreeBtn.addTarget(self, action: #selector(agreeClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(rejectBtn)
        NSLayoutConstraint.activate([
            rejectBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rejectBtn.rightAnchor.constraint(equalTo: agreeBtn.leftAnchor, constant: -16),
            rejectBtn.widthAnchor.constraint(equalToConstant: 60),
            rejectBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
        rejectBtn.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: rejectBtn.leftAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
    
    @objc func rejectClick(_ sender: UIButton){
        
    }
    
    @objc func agreeClick(_ sender: UIButton) {
        
    }

}
