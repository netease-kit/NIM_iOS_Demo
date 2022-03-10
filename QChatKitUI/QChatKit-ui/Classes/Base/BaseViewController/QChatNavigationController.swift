//
//  QChatNavigationController.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/24.
//

import UIKit

public class QChatNavigationController: UINavigationController {

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
       if children.count > 0 {
           viewController.hidesBottomBarWhenPushed = true
           if children.count > 1 {
               viewController.hidesBottomBarWhenPushed = false
           }
        }
        super.pushViewController(viewController, animated: true)
      }
}
