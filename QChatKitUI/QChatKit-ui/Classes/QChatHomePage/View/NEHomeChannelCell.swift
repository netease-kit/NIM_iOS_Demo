//
//  NEHomeChannelCell.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/26.
//

import UIKit
import CoreKit_IM

class NEHomeChannelCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public var channelModel:ChatChannel? {
        didSet {
            
            guard var name = channelModel?.name else { return  }
            name = "# \(name)"
            let attrStr = NSMutableAttributedString.init(string: name)
            attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value:PlaceholderTextColor, range:NSRange.init(location:0, length: 1))
            attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value:TextNormalColor, range:NSRange.init(location:1, length: name.count-1))
            channelNameLable.attributedText = attrStr
   
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func setupSubviews() {
        self.contentView.addSubview(channelNameLable)
        self.contentView.addSubview(redAngleView)

        NSLayoutConstraint.activate([
            channelNameLable.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 18),
            channelNameLable.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            channelNameLable.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,constant: -50),

        ])
        
        NSLayoutConstraint.activate([
            redAngleView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -18),
            redAngleView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            redAngleView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    


    private lazy var channelNameLable:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DefaultTextFont(16)
        label.textColor = TextNormalColor
        return label
    }()
    

    lazy var redAngleView:RedAngleLabel = {
        let label = RedAngleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DefaultTextFont(12)
        label.textColor = .white
        label.text = "99+"
        label.backgroundColor = HexRGB(0xF24957)
        label.textInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
}

//class RedAngleLabel: UILabel {
//    
//    var textInsets: UIEdgeInsets = .zero
//    override func drawText(in rect: CGRect) {
//        super.drawText(in: rect.inset(by: textInsets))
//    }
//    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        let insets = textInsets
//        var rect = super.textRect(forBounds: bounds.inset(by: insets),
//                                  limitedToNumberOfLines: numberOfLines)
//        
//        rect.origin.x -= insets.left
//        rect.origin.y -= insets.top
//        rect.size.width += (insets.left + insets.right)
//        rect.size.height += (insets.top + insets.bottom)
//        return rect
//    }
//    
//}
