//
//  ExtensionListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/06.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.

import UIKit
import Firebase

fileprivate let userRef = Firestore.firestore().user

extension ListViewController: UITabBarControllerDelegate {
    //MARK:- Feed로드
    func loadFesta() {
        FirebaseServices.shread.fecthMyFollowPosting { [weak self] in
            guard let self = self else { return }
            self.following = FirebaseServices.shread.following
            self.festaData = FirebaseServices.shread.myPostData
            self.myProfileData = FirebaseServices.shread.myProfile
            if !FirebaseServices.shread.followString.isEmpty || !self.festaData.isEmpty {
                self.postTableView.isHidden = false
                self.firstAlertLabel.isHidden = true
            } else {
                self.postTableView.isHidden = true
                self.firstAlertLabel.isHidden = false
            }
            self.refresh.endRefreshing()
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
        loadFesta()
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
            guard let topViewHeight = AnimationControl.shread.topViewHeight else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromTop, animations: { [weak self] in
                guard let self = self else { return }
                self.topView.alpha = 1.0
                self.leftTopButton.alpha = 1.0
            }) { [weak self] _ in
                guard let self = self else { return }
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
            guard let vc = UIStoryboard.notificationAlertVC() else { return }
            State.shread.sideViewBadgeCheck = false
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            guard let vc = UIStoryboard.myStoryVC() else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            guard let tabVC = storyboard?.instantiateViewController(withIdentifier: "tab2") as? UITabBarController else { return }
            State.shread.chattingCheck = false
            navigationController?.pushViewController(tabVC, animated: false)
        case 3:
            CommonService.shread.orderSelect = .logout
            presentAlert(.alert)
        default:
            print("selected Error : out of range")
        }
    }
    
    func dropdownButtonIsSelected(_ isSelected: Bool) {
        if isSelected == true {
            alertBadgeImageView.isHidden = true
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        guard let topViewHeight = AnimationControl.shread.topViewHeight else { return }
        if tabBarIndex == 0 {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.topView.alpha = 1.0
                self.leftTopButton.alpha = 1.0
                self.tableViewNSLayoutConstraint.constant = CGFloat(topViewHeight)
                self.postTableView.layoutIfNeeded()
                self.postTableView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
}



