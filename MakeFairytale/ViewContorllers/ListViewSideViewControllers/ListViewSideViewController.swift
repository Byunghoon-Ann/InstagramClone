//
//  ListViewSideViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/11/18.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
class ListViewSideViewController: UIViewController {
    
    @IBOutlet weak var myAlertListButton :UIButton!
    @IBOutlet weak var moveMyProflieButton :UIButton!
    @IBOutlet weak var moveChattingListButton :UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet var alertImageViews: [UIImageView]!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myAlertListButton.addTarget(self, action: #selector(myAlertLists), for: .touchUpInside)
        moveMyProflieButton.addTarget(self, action: #selector(moveMyprofile), for: .touchUpInside)
        moveChattingListButton.addTarget(self, action: #selector(moveChattingList), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        alertImageViews[0].layer.cornerRadius = alertImageViews[0].frame.height/2
        alertImageViews[1].layer.cornerRadius = alertImageViews[1].frame.height/2

        let currentUID = appDelegate.currentUID ?? ""
        LoadFile.shread.snapshotListenerCheckEvent(currentUID,
                                                   alertImageViews[0],
                                                   ["like","follow","reple"])
        LoadFile.shread.snapshotListenerCheckEvent(currentUID,
                                                   alertImageViews[1],
                                                   ["chatting"])
    }
    //알림 0 대화 2
    func checknotificationCenter() {
        let currentUID = appDelegate.currentUID ?? ""
        LoadFile.shread.snapshotListenerCheckEvent(currentUID, alertImageViews[0],["like","follow","chatting","reple"])
    }
    
    @objc func myAlertLists(_ sender: UIButton) {
        myAlertList()
    }
    
    @objc func moveMyprofile(_ sender: UIButton) {
        moveMyProfile()
        appDelegate.mySideView?.dismiss(animated: true)
    }
    
    @objc func moveChattingList(_ sender: UIButton) {
        testChattingViewMove()
        appDelegate.mySideView?.dismiss(animated: true)
    }
    
    @objc func logout(_ sender: UIButton) {
        logoutAuth()
        appDelegate.mySideView?.dismiss(animated: true)
    }
    
    func myAlertList() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationAlertViewController") as? NotificationAlertViewController else { return }
        let currentUID = appDelegate.currentUID ?? ""
        Firestore
            .firestore()
            .collection("user")
            .document(currentUID)
            .updateData(["like":false,
                         "follow":false,
                         "reple":false])
         
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: SideBar 2 : move MyProfileView
    func moveMyProfile() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyStoryViewController") as? MyStoryViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:SideBar 3 : move ChattingViewList
    func testChattingViewMove() {
        guard let tabVC = storyboard?.instantiateViewController(withIdentifier: "tab2") as? UITabBarController else { return }
        let currentUID = appDelegate.currentUID ?? ""
        Firestore
            .firestore()
            .collection("user")
            .document(currentUID)
            .updateData(["chatting":false])
        navigationController?.pushViewController(tabVC, animated: false)
    }
    
    //MARK:SideBar 4: logout
    func logoutAuth() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else  {return }
        let alert = UIAlertController(title: "안내",
                                      message: "로그아웃 하시겠습니까?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요",
                                         style: .cancel)
        let logoutAction = UIAlertAction(title: "네",
                                         style: .default) { _ in
                                            do {
                                                try Auth.auth().signOut()
                                                print("로그아웃 되었습니다")
                                            } catch let error {
                                                print("error: \(error.localizedDescription)")
                                            }
                                            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        self.present(alert,animated: true)
        
    }
}
