//
//  FollowListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/05/01.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

enum CheckMode {
    case following
    case follower
}

class FollowListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .white
        label.font = .boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var uid = ""

    var followingData = [FollowData]()
    var followerData = [FollowData]()
    var checkMode = CheckMode.following {
        didSet {
            switch checkMode {
            case .following:
                alertLabel.text = "팔로우한 사람이 없습니다.\n\n페스타들을 팔로우 해보세요!"
            case .follower:
                alertLabel.text = "팔로워한 사람이 없습니다.\n\n페스타님과 친목을 다져서\n\n 팔로워를 만들어보세요!"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        checkMode = .following
        labelUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFollowing(uid,true) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            if self.followingData.isEmpty {
                self.tableView.isHidden = true
                self.alertLabel.isHidden = false
            }else {
                self.tableView.isHidden = false
                self.alertLabel.isHidden = true
            }
        }
    }
    
    @IBAction func changingTableDataSegment(_ sender: Any) {
        if let _sender = sender as? UISegmentedControl {
             _sender.isSelected = !_sender.isSelected
            checkMode = _sender.isSelected ? .follower:.following
            tableView.reloadData()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension FollowListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch checkMode {
        case .follower:
            guard !followerData.isEmpty else {
                tableView.isHidden = true
                alertLabel.isHidden = false
                return 0
            }
            tableView.isHidden = false
            alertLabel.isHidden = true
            return followerData.count
        case .following:
            guard !followingData.isEmpty else {
                tableView.isHidden = true
                alertLabel.isHidden = false
                return 0
            }
            tableView.isHidden = false
            alertLabel.isHidden = true
            return followingData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FollowListCell = tableView.dequeueCell(indexPath: indexPath)
        switch checkMode {
        case .following:
            cell.checkType = .following
            cell.followData = followingData[indexPath.row]
        case .follower:
            cell.checkType = .follower
            cell.followData = followerData[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension FollowListViewController {
    func loadFollowing(_ uid: String,_ checkRepeat: Bool ,completion: @escaping ()-> Void) {
        if checkRepeat == true {
            let followRef = Firestore.firestore().followingRef(uid)
            followRef.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let _snapshot = snapshot?.documents else { return }
                if _snapshot.isEmpty {
                    self.loadFollowing(uid,false) { completion() }
                } else {
                    for i in _snapshot {
                        guard let _followingData = FollowData(document: i) else { return }
                        self.followingData.append(_followingData)
                        if self.followingData.count == _snapshot.count {
                            self.loadFollowing(uid,false) {
                                completion()
                            }
                        }
                    }
                }
            }
        } else {
           
            followerData.removeAll()
            let followerRef = Firestore.firestore().followerRef(uid)
            followerRef.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let _snapshot = snapshot?.documents else { return }
                if _snapshot.isEmpty {
                    completion()
                }else {
                    for i in _snapshot {
                        guard let data = FollowData(document: i) else { return }
                        self.followerData.append(data)
                        if _snapshot.count == self.followerData.count {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func labelUpdate() {
        view.addSubview(alertLabel)
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        alertLabel.isHidden = true
    }
}
