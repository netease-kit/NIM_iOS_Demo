//
//  QChatDetectNetworkTool.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/3/4.
//

import Foundation
import Alamofire



enum ReachabilityStatus{
    case notReachable
    case unknown
    case ethernetOrWiFi
    case wwan
 }

public class QChatDetectNetworkTool{
    
    public static let shareInstance = QChatDetectNetworkTool()
    let manager = NetworkReachabilityManager.init()

    
     func isNetworkRecahability() -> Bool {
       manager?.startListening()
       //通过一个代码块来处理监听结果
        manager?.listener = {
            stataus in
            self.manager?.stopListening()
        }
        return manager?.isReachable ?? false
    }
    
    func netWorkReachability(reachabilityStatus: @escaping(ReachabilityStatus)->Void){
       
        manager?.listener = {
            status in
            //wifi
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.reachable(.ethernetOrWiFi){
                print("------.wifi")
                reachabilityStatus(.ethernetOrWiFi)
           }
            //不可用
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable{
                print("------没网")
                reachabilityStatus(.notReachable)
            }
            //未知
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.unknown{
                print("------未知")
                reachabilityStatus(.unknown)
            }
            //蜂窝
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.reachable(.wwan){
                print("------蜂窝")
                reachabilityStatus(.wwan)
            }
        }
        manager?.startListening()
    }
}

