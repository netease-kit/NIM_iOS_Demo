//
//  QChatCornerCell.swift
//  NEKitQChatUI
//
//  Created by yu chen on 2022/1/22.
//

//this cell has rounding corner style
import UIKit

struct CornerType:OptionSet {
    let rawValue: Int
    static let none = CornerType(rawValue: 1)
    static let topLeft = CornerType(rawValue: 2)
    static let topRight = CornerType(rawValue: 4)
    static let bottomLeft = CornerType(rawValue: 8)
    static let bottomRight = CornerType(rawValue: 16)
}

class QChatCornerCell: QChatBaseCell {
    var cornerLayer = CAShapeLayer()
    public var fillColor: UIColor = .white
    public var edgeInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    private var type : CornerType = .none
    public var cornerType: CornerType {
            get { return type }
            set {
                if type != newValue {
                    type = newValue
                    sizeToFit()
                }
            }
        }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ne_lightBackgroundColor
        selectionStyle = .none
        self.layer.insertSublayer(cornerLayer, below: self.contentView.layer)
        print(#function)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func draw(_ rect: CGRect) {
        drawRoundedCorner(rect: rect)
        print(#function)
    }
    
    public func drawRoundedCorner(rect: CGRect) {
        var path: UIBezierPath = UIBezierPath()
        let roundRect = CGRect(x: rect.origin.x + edgeInset.left, y: rect.origin.y + edgeInset.top, width: rect.width - (edgeInset.left + edgeInset.right), height: rect.height - (edgeInset.top + edgeInset.bottom))
        if type == .none {
            path = UIBezierPath(rect: roundRect)
        }
        var corners = UIRectCorner()
        if type.contains(CornerType.topLeft) {
            corners = corners.union(.topLeft)
        }
        if type.contains(CornerType.topRight) {
            corners = corners.union(.topRight)
        }
        if type.contains(CornerType.bottomLeft) {
            corners = corners.union(.bottomLeft)
        }
        if type.contains(CornerType.bottomRight) {
            corners = corners.union(.bottomRight)
            
        }
        path = UIBezierPath(roundedRect:roundRect, byRoundingCorners: corners, cornerRadii: CGSize(width: 10, height: 10))
        
        cornerLayer.path = path.cgPath
        cornerLayer.fillColor = fillColor.cgColor
    }

}
