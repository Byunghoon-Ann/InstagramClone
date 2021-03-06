//
//  ChattingListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/29.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import SDWebImage
import ObjectMapper

fileprivate let followRef = Firestore.firestore().follow

class ChattingListViewController : UIViewController {
    
    var userData: [FollowData] = {
        let userData = FirebaseServices.shread.following
        return userData
    }()
    
    lazy var tableView = UITableView()
    lazy var alertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 2
        label.text = "페스타 찾기에서 친구를 \n 추가해 대화를 나눠보세요!"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChattingListViewCell.self, forCellReuseIdentifier: "ChattingListViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(view.frame.height/5)
            m.bottom.left.right.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFollowList()
    }
    
    func loadFollowList() {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        userData.removeAll()
        DispatchQueue.main.async {
            followRef
                .document("\(currentUID)")
                .collection("FollowList")
                .getDocuments { [weak self ] followList, error in
                    guard let self = self else { return }
                    guard let followList = followList?.documents else { return }
                    
                    if followList.isEmpty {
                        self.tableView.isHidden = true
                        self.alertLabel.isHidden = false
                    } else {
                        for i in followList {
                            guard let userData = FollowData(document: i) else { return }
                            self.userData.append(userData)
                            if self.userData.count == followList.count {
                                self.tableView.isHidden = false
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
        }
    }
    
    @IBAction func moveDidChattingRoomButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ChattingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < userData.count else { return  UITableViewCell() }
        let cell:ChattingListViewCell = tableView.dequeueCell(indexPath: indexPath)
        cell.backgroundColor = .white
        let imageView = cell.imageview
        
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(15)
            m.height.width.equalTo(50)
        }
        
        DispatchQueue.main.async {
            if self.userData[indexPath.row].userThumbnail.isEmpty || self.userData[indexPath.row].userThumbnail == "https://firebasestorage.googleapis.com/v0/b/festargram.appspot.com/o/ProfileImage%2FGa1gCzr889XNZMl21BudVge3m422?alt=media&token=f57776f4-e12f-4342-b6eb-8b343aa49a23" {
                imageView.image = UIImage(named: "userSelected@40x40")
            }else {
                
                imageView.sd_setImage(with: URL(string: self.userData[indexPath.row].userThumbnail))
            }
        }
        
        let label = cell.label
        label.backgroundColor = .white
        label.textColor = .black
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageView.snp.right).offset(30)
        }
        label.text = userData[indexPath.row].userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard.chattingRoomVC() else { return }
        CurrentUID.shread.yourUID = userData[indexPath.row].userUID
        navigationController?.pushViewController(vc, animated: false)
    }
}



