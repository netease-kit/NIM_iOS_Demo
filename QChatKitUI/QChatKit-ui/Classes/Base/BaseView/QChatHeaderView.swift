//
//  QChatHeaderView.swift
//  QChatKit-UI
//
//  Created by yu chen on 2022/1/26.
//

import UIKit

public class QChatHeaderView: UIView {
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DefaultTextFont(12)
        label.textColor = .ne_greyText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupUI(){
        clipsToBounds = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 33)
        ])
        backgroundColor = .clear
    }
    
    public func setTitle(_ name: String){
        titleLabel.text = name.count > 2 ? String(name[name.index(name.endIndex, offsetBy: -2)...]) : name
    }

}
