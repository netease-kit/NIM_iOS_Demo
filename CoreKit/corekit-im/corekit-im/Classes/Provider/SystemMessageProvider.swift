//
//  SystemMessageProvider.swift
//  CoreKit-IM
//
//  Created by yuanyuan on 2022/1/20.
//

import Foundation
import NIMSDK

public protocol SystemMessageProviderDelegate: AnyObject {
    func onRecieveNotification(notification: XNotification)
    func onNotificationUnreadCountChanged(count: Int)
}

public class SystemMessageProvider: NSObject, NIMSystemNotificationManagerDelegate {
    public static let shared = SystemMessageProvider()
    private let mutiDelegate = MultiDelegate<SystemMessageProviderDelegate>(strongReferences: false)
    private override init(){
        super.init()
        NIMSDK.shared().systemNotificationManager.add(self)
    }
    
    /// Gets system notifications stored locally
    /// - Parameter limit: The maximum number of notifications
    /// - Returns: List of notification
    public func getNotificationList(limit: Int) -> [XNotification] {
        var list: [XNotification] = []
        guard let notifications = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: limit) else {
            return list
        }
        for notification in notifications {
            list.append(detailNotification(notification: notification))
        }
        return list
    }
    
    private func detailNotification(notification: NIMSystemNotification?) -> XNotification {
        let noti = XNotification(notification: notification)
        switch noti.type {
        case .teamApply,.teamInvite,.teamApplyReject,.teamInviteReject:
            // team
            let targetTeam = TeamProvider.shared.teamInfo(teamId: noti.targetID)
            noti.targetName = targetTeam?.teamName
            
        case .superTeamApply,.superTeamInvite,.superTeamApplyReject,.superTeamInviteReject:
            // super team
            let targetTeam = TeamProvider.shared.superTeamInfo(teamId: noti.targetID)
            noti.targetName = targetTeam?.teamName
            
//            case .addFriendDirectly,.addFriendRequest,.addFriendVerify,.addFriendReject:
//                FIXME:因为是异步请求，所以暂时使用sourceID 作为SourceName
//                guard let source = noti.sourceID else {
//                    break
//                }
//                FriendProvider.shared.fetchUserInfo(accountList: [source]) { users, error in
//                    noti.sourceName = users?.first?.userInfo?.nickName
//                }
        default: break
        }
        return noti
    }
    
    //MARK: systemNotificationManagerDelegate
        public func onReceive(_ notification: NIMSystemNotification) {
            print("onReceive:\(notification)")
    //        invoke {
    //            $0.onRecieveNotification(notification:detailNotification(notification: notification))
    //        }
            mutiDelegate |> { delegate in
                delegate.onRecieveNotification(notification:detailNotification(notification: notification))
            }
        }
        public func onSystemNotificationCountChanged(_ unreadCount: Int) {
            print("unreadCount:\(unreadCount)")
            mutiDelegate |> { delegate in
                delegate.onNotificationUnreadCountChanged(count: unreadCount)
            }
    //        invoke {
    //            $0.onNotificationUnreadCountChanged(count: unreadCount)
    //        }
        }
    
    public func deleteNoti(){
        NIMSDK.shared().systemNotificationManager.deleteAllNotifications()
    }
    
    public func getUnreadCount() -> Int{
       return NIMSDK.shared().systemNotificationManager.allUnreadCount()
    }
    
    public func clearUnreadCount(){
        NIMSDK.shared().systemNotificationManager.markAllNotificationsAsRead()
    }
    
//MARK: Delegate
    public func addDelegate(delegate:SystemMessageProviderDelegate) {
        mutiDelegate.addDelegate(delegate)
    }
    public func removeDelegate(delegate: SystemMessageProviderDelegate) {
        mutiDelegate.removeDelegate(delegate)
    }
}
