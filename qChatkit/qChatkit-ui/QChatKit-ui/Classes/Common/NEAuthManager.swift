//
//  NEAuthManager.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/25.
//

import AVFoundation
import Photos

public typealias NEAuthCompletion = (_ granted: Bool) -> Void

@objc
public class YXAuthManager: NSObject {
    

    /// 查询相机授权
    @objc
    public class func hasCameraAuthorization() -> Bool {
        let state = AVCaptureDevice.authorizationStatus(for: .video)
        return state == .authorized
    }

    /// 请求相机权限
    /// @param completion 结果
    @objc
    public class func requestCameraAuthorization(_ completion: NEAuthCompletion?) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    
    ///相册权限
    /// - Parameter completion: 结果
    class func photoAlbumPermissions(_ completion:NEAuthCompletion?) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        // .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                self.photoAlbumPermissions(completion)
            }
        } else if authStatus == .authorized  {
            if completion != nil {
                completion!(true)
            }
        } else {
            if completion != nil {
                completion!(false)
            }
        }
    }


}
