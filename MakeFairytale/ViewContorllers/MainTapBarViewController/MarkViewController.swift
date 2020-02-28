//
//  MarkViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 04/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//좋아요 뷰, 좋아요한 게시글을 모아 테이블뷰로 구현

import Foundation
import UIKit
import SDWebImage
import Firebase
fileprivate let firestoreRef = Firestore.firestore()
class MarkViewController : UIViewController {
    
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var goodPost: [Posts] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var alertLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 3
        label.textColor = .black
        label.backgroundColor = .clear
        label.text = "좋아요 한 게시물이 없습니다.\n 많은 페스타들의 게시물을 둘러보시고 \n 좋아요를 눌러주세요! "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initRefresh()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(alertLabel)
        self.alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGoodMarkPost {
            self.tableView.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        count = 0
    }
}

extension MarkViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard goodPost.count > 0 else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MarkViewCell") as? MarkViewCell else { return UITableViewCell() }
        cell.profileImageView.sd_setImage(with: URL(string: goodPost[indexPath.row].userProfileImage))
        cell.userName.text = goodPost[indexPath.row].userName
        cell.userComment.text = goodPost[indexPath.row].userComment
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewPostingController") as? ViewPostingController else { return }
        vc.post = goodPost[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MarkViewController {
    func loadGoodMarkPost(completion : @escaping () -> Void) {
        activityIndicatior.startAnimating()
        guard let currentUID = appDelegate.currentUID else { return }
        goodPost.removeAll()
        appDelegate.goodPost.removeAll()
        firestoreRef
            .collection("AllPost")
            .getDocuments { allSnapshot, error in
                guard let allSnapshot = allSnapshot?.documents else { return }
                if allSnapshot.isEmpty {
                    self.tableView.isHidden = true
                    self.alertLabel.isHidden = false
                    completion()
                } else {
                    for i in allSnapshot {
                        guard let post = i.data() as? [String:[String:Any]] else { return }
                        let postID = i.documentID
                        
                        firestoreRef
                            .collection("AllPost")
                            .document(postID)
                            .collection("goodMarkLog")
                            .document(currentUID)
                            .getDocument { snapshot, error in
                                
                                firestoreRef
                                    .collection("AllPost")
                                    .document(postID)
                                    .collection("ViewCheck")
                                    .getDocuments { viewCheck, error in
                                        
                                        firestoreRef
                                            .collection("AllPost")
                                            .document(postID)
                                            .collection("goodMarkLog")
                                            .getDocuments { likeCheck, error in
                                                for (_,j) in post {
                                                    self.count += 1
                                                    var like = false
                                                    if let snapshot = snapshot?.data() {
                                                        var viewCount = 0
                                                        var likeCounts = 0
                                                        like = snapshot["like"] as? Bool ?? false
                                                        let name = j["nickName"] as? String ?? ""
                                                        let postComment = j["postComment"] as? String ?? ""
                                                        let postImageURL = j["postImageURL"] as? [String] ?? [""]
                                                        let date = j["date"] as? String ?? ""
                                                        let profile = j["profileImageURL"] as? String ?? ""
                                                        let uid = j["uid"] as? String  ?? ""
                                                        if let viewCheck = viewCheck {
                                                            viewCount = viewCheck.count
                                                        }
                                                        
                                                        if let likeCheck = likeCheck?.documents {
                                                            for check in likeCheck {
                                                                let likes = check["like"] as? Bool ?? false
                                                                if likes == true {
                                                                    likeCounts += 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        if like == true {
                                                            self.goodPost.append(Posts(userUID: uid,
                                                                                       userName: name,
                                                                                       userComment: postComment,
                                                                                       userProfileImage: profile,
                                                                                       userPostImage: postImageURL,
                                                                                       postDate: date,
                                                                                       goodMark: like,
                                                                                       viewCount: viewCount,
                                                                                       likeCount: likeCounts,
                                                                                       urlkey: postID))
                                                        }
                                                    } else {
                                                        if allSnapshot.count == self.count, self.goodPost.isEmpty{
                                                            self.activityIndicatior.isHidden = true
                                                            self.tableView.isHidden = true
                                                            self.alertLabel.isHidden = false
                                                            completion()
                                                            break
                                                        } else {
                                                            continue
                                                        }
                                                    }
                                                }
                                                if allSnapshot.count == self.count, !self.goodPost.isEmpty {
                                                    self.alertLabel.isHidden = true
                                                    self.activityIndicatior.isHidden = true
                                                    self.tableView.isHidden = false
                                                    
                                                    self.tableView.reloadData()
                                                    completion()
                                                }
                                        }
                                }
                        }
                    }
                }
        }
    }
    
    func initRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(refresh:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl =  refresh
        }else {
            tableView.addSubview(refresh)
        }
    }
    
    @objc func refresh(refresh: UIRefreshControl) {
        loadGoodMarkPost {
            self.tableView.reloadData()
            self.tableView.isHidden = false
            refresh.endRefreshing()
        }
    }
}
