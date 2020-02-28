//
//  MyListFeedSideBar.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/11/18.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import SideMenu
class MyListFeedSideBar: SideMenuNavigationController {
    let customSideMenu = SideMenuManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        appDelegate.mySideView = self
        self.menuWidth = 100
    }
}
