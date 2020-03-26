//
//  ExtensionListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//
import UIKit
import Firebase

fileprivate let firestoreRef = Firestore.firestore()

extension ListViewController {
    //MARK:- Feed로드
    func loadFesta(_ profileImageView: UIImageView,
                   _ userNameLabel: UILabel,
                   _ indicator: UIActivityIndicatorView,
                   _ tableview: UITableView,
                   _ today: Date,
                   _ dateFomatter: DateFormatter)
                   {
            LoadFile.shread.fecthMyFollowPosting {
                tableview.isHidden = true
                indicator.startAnimating()
                self.following = LoadFile.shread.following
                self.follwingCollectionView.reloadData()
                LoadFile.shread.fecthFollowPost {
                    LoadFile.shread.loadMyFeed {
                        self.festaData.removeAll()
                        self.festaData = LoadFile.shread.myPostData
                        
                        self.festaData.sort { firstItem, secondItem in
                            let firstDate = dateFomatter.date(from: firstItem.postDate) ?? today
                            let secondDate = dateFomatter.date(from: secondItem.postDate) ?? today
                            
                            if  firstDate > secondDate {
                                return true
                            } else {
                                return false
                            }
                        }
                        self.loadProfile {
                            guard let myProfileData = self.myProfileData else { return }
                            profileImageView.sd_setImage(with: URL(string: myProfileData.profileImageURL))
                            userNameLabel.text = myProfileData.nickName
                            
                            if !LoadFile.shread.followString.isEmpty || !self.festaData.isEmpty {
                                tableview.isHidden = false
                                self.firstAlertLabel.isHidden = true
                                tableview.reloadData()
                            }else {
                                self.firstAlertLabel.isHidden = false
                            }
                            self.refresh.endRefreshing()
                            indicator.stopAnimating()
                            indicator.isHidden = true
                        }
                    }
                }
                    }
    }
    
    //MARK:- 사용자 정보 로드
    func loadProfile(completion : @escaping () -> Void) {
        myProfileData = nil
        
        guard let currentUID = self.appDelegate.currentUID else { return }
        firestoreRef
            .collection("user")
            .document("\(currentUID)")
            .getDocument() { snapshot,error in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    guard let snapshot = snapshot?.data() else { return }
                    let nickName = snapshot["nickName"] as? String ?? ""
                    let email = snapshot["email"] as? String  ?? ""
                    let profileImage = snapshot["profileImageURL"] as? String ?? ""
                    self.myProfileData = MyProfile(profileImageURL: profileImage,
                                                   email: email,
                                                   nickName: nickName,
                                                   uid: currentUID)
                    self.appDelegate.myProfile = self.myProfileData
                    completion()
                }
        }
    }
    
    //MARK:- 새로고침
    func initRefresh(_ refresh: UIRefreshControl) {
        refresh.addTarget(self, action: #selector(refresh(refresh:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            postTableView.refreshControl =  refresh
        }else {
            postTableView.addSubview(refresh)
        }
        
    }
    
    //MARK:-새로고침시 발생하는 Event
    @objc func refresh(refresh: UIRefreshControl) {
        loadFesta(userProfileImageView,
                  userProfileName,
                  postLoadingIndicatior,
                  postTableView,
                  date,
                  dateFomatter)
    }
    
    //MARK:- 해당 게시물 유저와 채팅 Event
    func moveChattingViewController(_ button: UIButton,
                                    _ tableView: UITableView,
                                    _ postData: [Posts]) {
        let contentView = button.superview
        guard let cell = contentView?.superview as? FeedCollectionCell else  { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChattingRoomViewController") as? ChattingRoomViewController else { return }
        vc.yourUID = postData[indexPath.row].userUID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func topViewHideSwipeGesture(_ tableView: UITableView) {
        let hideDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideDownViewGesture(_:)))
        hideDownGesture.direction = .down
        let hideUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideUpViewGesture(_:)))
        hideUpGesture.direction = .up
        tableView.addGestureRecognizer(hideDownGesture)
        tableView.addGestureRecognizer(hideUpGesture)
        hideDownGesture.delegate = self
        hideUpGesture.delegate = self
    }
    
    @objc func hideUpViewGesture (_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up {
            topViewHideCheck = true
            UIView.animate(withDuration: 0.2 ,animations: {
                self.topView.alpha = 0.0
                self.leftTopButton.alpha = 0.0
            }) { _ in
                UIView.animate(withDuration: 0.25) {
                    self.tableViewNSLayoutConstraint.constant = 0
                    self.postTableView.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func hideDownViewGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            guard let topViewHeight = appDelegate.topViewHeight else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromTop, animations: {
                self.topView.alpha = 1.0
                self.leftTopButton.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.25 ,animations: {
                    self.tableViewNSLayoutConstraint.constant = CGFloat(topViewHeight)
                    self.postTableView.layoutIfNeeded()
                })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage{
            if flagImageSave {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            dismiss(animated: true, completion: nil)
            tabBarController?.selectedIndex = 2
        }
    }
    
    func dropDownButtonSet(){
        view.addSubview(leftTopButton)
        leftTopButton.delegate = self
        leftTopButton.translatesAutoresizingMaskIntoConstraints = false
        leftTopButton.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor,constant: -30).isActive = true
        leftTopButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        leftTopButton.centerYAnchor.constraint(equalTo: topUIView.centerYAnchor).isActive = true
        leftTopButton.setImage(UIImage(named: "icon-small"), for: .normal)
    }
    
    func didSelectedDropDownView(_ path: Int) {
        switch path {
        case 0:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationAlertViewController") as? NotificationAlertViewController else { return }
            appDelegate.sideViewBadgeCheck = false
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyStoryViewController") as? MyStoryViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            guard let tabVC = storyboard?.instantiateViewController(withIdentifier: "tab2") as? UITabBarController else { return }
            appDelegate.chattingCheck = false
            navigationController?.pushViewController(tabVC, animated: false)
        case 3:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else  { return }
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
        default:
            print("error selected")
        }
    }
    
    func dropdownButtonIsSelected(_ isSelected: Bool) {
        if isSelected == true {
            alertBadgeImageView.isHidden = true
        }
    }
}



