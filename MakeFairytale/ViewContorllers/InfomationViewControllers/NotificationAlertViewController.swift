//
//  NotificationAlertViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/11.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.

import UIKit
import Firebase
import SDWebImage

fileprivate let firestoreRef = Firestore.firestore()
fileprivate let currentUID = Auth.auth().currentUser?.uid
class NotificationAlertViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var firstAlertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = "아직 알림이 없습니다. "
        label.textAlignment = .center
        return label
    }()
    
    lazy var dateFomatter : DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    lazy var today = Today.shread.today
    var alertsDatas: [NotificationData] = [] {
        didSet {
            if !self.alertsDatas.isEmpty {
                tableView.isHidden = false
                self.alertsDatas.sort { firstData, secondData in
                    let firstDate = self.dateFomatter.date(from: firstData.alertDate) ?? self.today
                    let secondDate = self.dateFomatter.date(from: secondData.alertDate) ?? self.today
                    if firstDate > secondDate {
                        return true
                    }
                    return false
                }
            } else {
                tableView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(firstAlertLabel)
        firstAlertLabel.isHidden = true
        firstAlertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstAlertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backButton.addTarget(self, action: #selector(checkAlertBackButton), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        loadAlerts{ [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    @objc func checkAlertBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  alertsDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < alertsDatas.count else { return UITableViewCell() }
        let cell:NotificationAlertTableCell = tableView.dequeueCell(indexPath: indexPath)
        cell.alertsData = alertsDatas[indexPath.row]
        return cell
    }
    
}

extension NotificationAlertViewController {
    
    func loadAlerts(completion : @escaping () -> Void) {
        alertsDatas.removeAll()
        guard let currentUID = currentUID else { return }
        activityIndicator.startAnimating()
        tableView.isHidden = true
        DispatchQueue.main.async {
            firestoreRef
                .collection("NotificationCenter")
                .document(currentUID)
                .collection("alert")
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    guard let snapshot = snapshot?.documents else { return }
                    guard snapshot.count > 0 else  {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.firstAlertLabel.isHidden = false
                        completion()
                        return }
                    for i in snapshot {
                        let alertData = i.data()
                        let alertComment = alertData["message"] as? String ?? ""
                        let nickName = alertData["nickName"] as? String ?? ""
                        let alertDate = alertData["date"] as? String ?? ""
                        let userUID = alertData["uid"] as? String ?? ""
                        
                        firestoreRef
                            .collection("user")
                            .document(userUID)
                            .getDocument{ userData, error in
                                guard let userData = userData?.data() else {
                                    self.alertsDatas.append(NotificationData(userName: nickName,
                                                                             userThumbnail: "",
                                                                             userUID: userUID,
                                                                             alertDate: alertDate,
                                                                             alertContent: alertComment))
                                    return }
                                let profileImageURL = userData["profileImageURL"] as? String ?? ""
                                
                                self.alertsDatas.append(NotificationData(userName: nickName,
                                                                         userThumbnail: profileImageURL,
                                                                         userUID: userUID,
                                                                         alertDate: alertDate,
                                                                         alertContent: alertComment))
                                if snapshot.count == self.alertsDatas.count {
                                    completion()
                                }
                        }
                    }
            }
        }
    }
}
