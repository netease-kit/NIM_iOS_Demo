//
//  QChatShowImageController.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/3/7.
//

import Foundation

public class QChatShowImageController: UIViewController {
    
    private let SystemNaviBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 24
    
    /// 默认不显示
    public var showSaveBtn: Bool = false {
        didSet {
            if showSaveBtn {
                self.saveBtn.isHidden = false
            }else{
                self.saveBtn.isHidden = true
            }
        }
    }
    
    /// 可重写saveBtn样式
    public lazy var saveBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("保存至相册", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.isHidden = true
        return button
    }()
    
    internal var showView: QChatShowBigImgBackView
    internal var number: Int
    public init(imgs: [UIImage],img: UIImage) {
        var number = 0
        _ = imgs.enumerated().map { (index,urlStr) in
            if urlStr == img {
                number = index
            }
        }
        self.number = number
        self.showView = QChatShowBigImgBackView(imgArr: imgs, number: number)
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(urls: [String],url: String) {
        var number = 0
        _ = urls.enumerated().map { (index,urlStr) in
            if urlStr == url {
                number = index
            }
        }
        self.number = number
        self.showView = QChatShowBigImgBackView.init(urlArr: urls, number: number)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.layoutViews()
        self.saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
    }
    
    func layoutViews() {
        self.view.addSubview(self.showView)
        self.view.addSubview(self.saveBtn)
        self.showView.dismissCallBack = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        self.saveBtn.translatesAutoresizingMaskIntoConstraints = false
        self.saveBtn.heightAnchor.constraint(equalToConstant: 16).isActive = true
        self.saveBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.saveBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: SystemNaviBarHeight).isActive = true
        self.saveBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
    }
    
    // 保存图片
    @objc func saveBtnClick() {
       
        showToast("保存中...")
        let index = Int(self.showView.collectionView.contentOffset.x / kScreenWidth)
        
        if self.showView.urlArr.count > 0 {
            let url = self.showView.urlArr[index]
            guard let data = try? Data.init(contentsOf: URL(string: url)!) else {
                return
            }
            //保存图片
        }else{
            let img = self.showView.imgArr[index]
            //保存图片
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showView.transformAnimation()
    }

}
