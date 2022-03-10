//
//  AppDelegate.swift
//  app
//
//  Created by yu chen on 2021/12/28.
//

import UIKit
import ContactKit_UI
import YXLogin
import CoreKit
import NIMSDK
import QChatKit_UI
import CoreKit_IM
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = .white
        setupInit()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRoot), name: Notification.Name("logout"), object: nil)
        return true
    }
        
    func setupInit(){
        // init
        let option = NIMSDKOption()
        option.appKey = AppKey.appKey
        CoreKitEngine.instance.setupCoreKit(option)
        
        // login to business server
        let config = YXConfig()
        config.appKey = AppKey.appKey
        config.parentScope = NSNumber(integerLiteral: 2)
        config.scope = NSNumber(integerLiteral: 7)
        config.supportInternationalize = false
        config.type = .phone
        #if DEBUG
        config.isOnline = false
        #else
        config.isOnline = true
        #endif
        AuthorManager.shareInstance()?.initAuthor(with: config)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        weak var weakSelf = self
        if let canAutoLogin = AuthorManager.shareInstance()?.canAutologin(), canAutoLogin == true {
            AuthorManager.shareInstance()?.autoLogin(completion: { user, error in
                if let err = error{
                    print("auto login error : ", err)
                    weakSelf?.loginWithUI()
                }else {
                    print("login accid : ", user?.imAccid as Any)
                    weakSelf?.setupSuccessLogic(user)
                }
            })
        }else {
            loginWithUI()
        }
    }
    
    @objc func refreshRoot(){
        print("refresh root")
        loginWithUI()
    }
    
    func loginWithUI(){
        weak var weakSelf = self
        AuthorManager.shareInstance()?.startLogin(completion: { user, error in
            if let err = error{
                print("login error : ", err)
            }else {
                weakSelf?.setupSuccessLogic(user)
            }
        })
    }
    
    func setupSuccessLogic(_ user: YXUserInfo?){
        setupXKit(user)
    }
    
    func setupXKit(_ user: YXUserInfo?){
        if let token = user?.imToken, let account = user?.imAccid {
            weak var weakSelf = self
            CoreKitEngine.instance.login(account, token) { error in
                if let err = error {
                    print("corekit login error : ", err)
                }else {
                    let param = QChatLoginParam(account,token)
                    CoreKitIMEngine.instance.loginQchat(param) { error, response in
                        if let err = error {
                            print("qchatLogin failed, error : ", err)
                        }else {
                            weakSelf?.setupTabbar()
                        }
                    }
                }
            }
        }
    }
    
    func setupTabbar() {
        //qchat
        let qchat = QChatHomeViewController()
        qchat.view.backgroundColor = UIColor.init(hexString: "#e9eff5")
        qchat.tabBarItem = UITabBarItem(title: "圈组", image: UIImage(named: "qchat_tabbar_icon"), selectedImage: UIImage(named: "qchat_tabbar_icon")?.withRenderingMode(.alwaysOriginal))
        let qChatNav = QChatNavigationController.init(rootViewController: qchat)
        
        // Contacts
        let uiConfig = ContactsConfig()
        // example uiConfig.cellNameFont = ...
        let contactVC = ContactsViewController(withConfig: uiConfig)
        contactVC.tabBarItem = UITabBarItem(title: "通讯录", image: UIImage(named: "contact"), selectedImage: UIImage(named: "contactSelect")?.withRenderingMode(.alwaysOriginal))
        contactVC.title = "通讯录"
        let contactsNav = QChatNavigationController.init(rootViewController: contactVC)
        
        // Me
        let meVC = MeViewController()
        meVC.view.backgroundColor = UIColor.white
        meVC.tabBarItem = UITabBarItem(title: "我", image: UIImage(named: "person"), selectedImage: UIImage(named: "personSelect")?.withRenderingMode(.alwaysOriginal))
        let meNav = QChatNavigationController.init(rootViewController: meVC)

        // tabbar
        let tabbar: UITabBarController = UITabBarController()
        tabbar.tabBar.backgroundColor = .white
        tabbar.viewControllers = [qChatNav,contactsNav,meNav]
        tabbar.selectedIndex = 0
        self.window?.rootViewController = tabbar
        loadService()
    }
    
//    regist router
    func loadService() {
        ContactRouter.register()
    }
    

}

