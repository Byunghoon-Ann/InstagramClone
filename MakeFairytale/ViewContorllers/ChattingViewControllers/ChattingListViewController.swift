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

fileprivate let firestoreRef = Firestore.firestore()

class ChattingListViewController : UIViewController {
    var userData : [MyData] = []
    var tableView = UITableView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "페스타 찾기에서 친구를 추가해 대화를 나눠보세요!"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChattingListViewCell.self, forCellReuseIdentifier: "ChattingCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(view.frame.height/6)
            m.bottom.left.right.equalTo(view)
        }
        loadFollowList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFollowList()
    }
    
    func loadFollowList() {
        guard let currentUID = appDelegate.currentUID else { return }
        userData.removeAll()
        DispatchQueue.main.async {
            firestoreRef
                .collection("Follow")
                .document("\(currentUID)")
                .collection("FollowList")
                .getDocuments { followList, error in
                    guard let followList = followList?.documents else { return }
                    
                    if followList == [] {
                        self.alertLabel.isHidden = false
                    } else {
                        for i in followList {
                            let followdata = i.data()
                            let uid = followdata["uid"] as? String ?? ""
                            let profile = followdata["profileImageURL"] as? String ?? ""
                            let nickName = followdata["nickName"] as? String ?? ""
                            let listData = MyData(userName: nickName, userThumbnail: profile, userUID: uid)
                            self.userData.append(listData)
                            if self.userData.count == followList.count {
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
        guard userData.count > 0 else { return  UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChattingCell",for: indexPath) as? ChattingListViewCell else {return UITableViewCell() }
        
        let imageView = cell.imageview
        
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(15)
            m.height.width.equalTo(50)
        }
        
        DispatchQueue.main.async {
            imageView.sd_setImage(with: URL(string: self.userData[indexPath.row].userThumbnail))
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.clipsToBounds = true
        }
        
        let label = cell.label
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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChattingRoomViewController") as? ChattingRoomViewController else { return }
        
        vc.yourUID = userData[indexPath.row].userUID
        navigationController?.pushViewController(vc, animated: false)
    }
}



