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
}
