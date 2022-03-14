//
//  QChatUserHeaderView.swift
//  NEKitQChatUI
//
//  Created by chenyu on 2022/2/5.
//

import UIKit

public class QChatUserHeaderView: UIImageView {


    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DefaultTextFont(12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupUI(){
        isUserInteractionEnabled = true
        clipsToBounds = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor
                .constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        backgroundColor = .clear
    }
    
    public func setTitle(_ name: String){
        titleLabel.text = name.count > 2 ? String(name[name.index(name.endIndex, offsetBy: -2)...]) : name
    }

}
