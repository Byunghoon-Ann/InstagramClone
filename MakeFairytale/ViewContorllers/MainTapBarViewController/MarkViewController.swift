//
//  MarkViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 04/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//좋아요 뷰, 좋아요한 게시글을 모아 테이블뷰로 구현

import UIKit
import Firebase
fileprivate let postRef = Firestore.firestore().posts
fileprivate let userRef = Firestore.firestore().user
class MarkViewController : UIViewController {
    
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var goodPost: [Posts] = []
    
    var alertLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 3
        label.textColor = .black
        label.backgroundColor = .white
        label.text = "좋아요 한 게시물이 없습니다.\n 많은 페스타들의 게시물을 둘러보시고 \n 좋아요를 눌러주세요! "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initRefresh()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        view.addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGoodMarkPost {
            self.activityIndicatior.stopAnimating()
            self.activityIndicatior.isHidden = true
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
        guard indexPath.row < goodPost.count else { return UITableViewCell() }
        let cell:MarkViewCell = tableView.dequeueCell(indexPath:indexPath)
        cell.backgroundColor = .white
        cell.post = goodPost[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard.viewPostingVC() else { return }
        vc.post = goodPost[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height/9
    }
}

extension MarkViewController {
    func loadGoodMarkPost(completion : @escaping () -> Void) {
        activityIndicatior.startAnimating()
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        goodPost.removeAll()
        postRef.getDocuments { [weak self] allSnapshot, error in
            guard let self = self else { return }
            guard let allSnapshot = allSnapshot?.documents else { return }
            if allSnapshot.isEmpty {
                self.tableView.isHidden = true
                self.alertLabel.isHidden = false
                completion()
            } else {
                for i in allSnapshot {
                    self.count += 1
                    let postID = i.documentID
                    let likeUrl = Firestore.firestore().goodMark(postID)
                    let viewUrl = Firestore.firestore().viewCount(postID)
                    
                    likeUrl.document(currentUID).getDocument {snapshot, error in
                        viewUrl.getDocuments { viewCheck, error in
                            likeUrl.getDocuments { likeCheck,error  in
                                Posts.cleanData(allSnapshot.count,
                                                i.data() as? [String:[String:Any]] ,
                                                postID,
                                                userRef,
                                                viewUrl,
                                                likeUrl,
                                                currentUID,
                                                snapshot,
                                                viewCheck,
                                                likeCheck) { data in
                                                    if data.goodMark == true {
                                                        self.goodPost.append(data)
                                                    }
                                                    if allSnapshot.count == self.count {
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
