//
//  ViewControllerExtension.swift
//  QChatKit-UI
//
//  Created by yu chen on 2022/1/26.
//

import UIKit
import AVFoundation

typealias AlertCallBack = () -> Void

extension UIViewController: UIImagePickerControllerDelegate {
    
     var rightNavBtn: ExpandButton {
        get {
            if let btn = objc_getAssociatedObject(self, UnsafeRawPointer.init(bitPattern: "rightNavBtn".hashValue)!) as? ExpandButton {
                return btn
            }else {
                let btn = ExpandButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
                self.rightNavBtn = btn
                btn.setTitleColor(.ne_blueText, for: .normal)
                btn.titleLabel?.font = DefaultTextFont(16)
                return btn
            }
        }
         
        set {
            objc_setAssociatedObject(self, UnsafeRawPointer.init(bitPattern: "rightNavBtn".hashValue)!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var leftNavBtn: ExpandButton {
       get {
           if let btn = objc_getAssociatedObject(self, UnsafeRawPointer.init(bitPattern: "leftNavBtn".hashValue)!) as? ExpandButton {
               return btn
           }else {
               let btn = ExpandButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
               self.leftNavBtn = btn
               btn.setTitleColor(.ne_darkText, for: .normal)
               btn.titleLabel?.font = DefaultTextFont(16)
               return btn
           }
       }
       set {
           objc_setAssociatedObject(self, UnsafeRawPointer.init(bitPattern: "leftNavBtn".hashValue)!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
       }
   }
    
    func addLeftAction(_ image: UIImage?, _ selector: Selector, _ target: Any?){
        let leftItem = UIBarButtonItem(image: image, style: .plain, target: target, action: selector)
        leftItem.tintColor = .ne_greyText
        navigationItem.leftBarButtonItem = leftItem
    }
    
    func addLeftAction(_ title: String, _ selector: Selector, _ target: Any?){
        leftNavBtn.addTarget(target, action: selector, for: .touchUpInside)
        leftNavBtn.setTitle(title, for: .normal)
        let leftItem = UIBarButtonItem(customView: leftNavBtn)
        leftItem.tintColor = .ne_blueText
        navigationItem.leftBarButtonItem = leftItem
    }
    
    
    func addRightAction(_ image: UIImage?, _ selector: Selector, _ target: Any?){
        let rightItem = UIBarButtonItem(image: image, style: .plain, target: target, action: selector)
        rightItem.tintColor = .ne_greyText
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func addRightAction(_ title: String, _ selector: Selector, _ target: Any?){
        rightNavBtn.addTarget(target, action: selector, for: .touchUpInside)
        rightNavBtn.setTitle(title, for: .normal)
        let rightItem = UIBarButtonItem(customView: rightNavBtn)
        rightItem.tintColor = .ne_blueText
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func showAlert(title: String = localizable("qchat_tip"), message: String?, sureText: String = localizable("qchat_sure"), cancelText: String = localizable("qchat_cancel"), _ sureBack: @escaping AlertCallBack, cancelBack: AlertCallBack? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        let cancelAction = UIAlertAction(title: cancelText, style: .default) { action in
            if let block = cancelBack {
                block()
            }
        }
        alertController.addAction(cancelAction)
        let sureAction = UIAlertAction(title: sureText, style: .default) { action in
            sureBack()
        }
        alertController.addAction(sureAction)
        print("show alert view")
        present(alertController, animated: true, completion: nil)
    }
    
    func showToast(_ message: String){
        UIApplication.shared.keyWindow?.endEditing(true)
        view.makeToast(message, duration: 2, position: .center)
    }
    
    func showToastInWindow(_ message: String){
        UIApplication.shared.keyWindow?.endEditing(true)
        UIApplication.shared.keyWindow?.makeToast(message)
    }
    
    func showBottomAlert(_ delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        
        if !QChatDetectNetworkTool.shareInstance.isNetworkRecahability() {
            showToast("当前网络错误")
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title:localizable("取消"), style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.ne_darkText, forKey: "_titleTextColor")
        
        let takingPicturesAction = UIAlertAction(title:localizable("拍照"), style: .default){ action in
            self.goCamera(delegate)
        }
        takingPicturesAction.setValue(UIColor.ne_darkText, forKey: "_titleTextColor")

        let localPhotoAction = UIAlertAction(title:localizable("从相册选择"), style: .default){ action in
            self.goPhotoAlbum(delegate)
        }
        localPhotoAction.setValue(UIColor.ne_darkText, forKey: "_titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(takingPicturesAction)
        alertController.addAction(localPhotoAction)
        self.present(alertController, animated:true, completion:nil)
    }
    
    func goCamera(_ delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == .authorized) {//已授权，可以打开相机
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = delegate
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
               
        } else if (authStatus == .denied) {
            
            showAlert(message: "请去-> [设置 - 隐私 - 相机] 打开访问开关") {}

       } else if (authStatus == .restricted) {//相机权限受限
           
           showAlert(message: "相机权限受限") {}

       } else if (authStatus == .notDetermined) {//首次 使用
           AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
               if statusFirst { //用户首次允许
                   let  cameraPicker = UIImagePickerController()
                   cameraPicker.delegate = delegate
                   cameraPicker.allowsEditing = true
                   cameraPicker.sourceType = .camera
                   //在需要的地方present出来
                   DispatchQueue.main.async {
                       self.present(cameraPicker, animated: true, completion: nil)
                   }
               } else {//用户首次拒接
                   
               }
           })
       }
    }
        
    func goPhotoAlbum(_ delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        YXAuthManager.requestCameraAuthorization { granted in
            if granted {
                let photoPicker =  UIImagePickerController()
                photoPicker.delegate = delegate
                photoPicker.allowsEditing = true
                photoPicker.sourceType = .photoLibrary
                //在需要的地方present出来
                self.present(photoPicker, animated: true, completion: nil)
            }else {
                self.view.makeToast("未打开相册权限")
            }
        }
    }
 
}

