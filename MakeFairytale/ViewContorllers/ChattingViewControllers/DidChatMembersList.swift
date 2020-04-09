//
//  DidChatMembersList.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/31.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import Foundation
import UIKit
import Firebase
fileprivate let databaseRef = Database.database().reference()
fileprivate let firestoreRef = Firestore.firestore()

class DidChatMembersList : UIViewController {
 
    
    @IBOutlet weak var tableView: UITableView!
    
    var firstAlertLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.backgroundColor = .white
        label.text = "대화한 기록이 없습니다. \n팔로우한 친구와 대화를 나눠보세요!"
        label.textAlignment = .center
        return label
    }()
    var chatModel: [ChatModel] = []
    var yourUIDs : [String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        view.addSubview(firstAlertLabel)
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        
        firstAlertLabel.isHidden = true
        firstAlertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstAlertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        getChatRoomList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidLoad()
    }
    
    func getChatRoomList() {
        guard let currentUID = appDelegate.currentUID else { return }
        databaseRef
            .child("chatRooms")
            .queryOrdered(byChild: "users/"+currentUID)
            .queryEqual(toValue: true)
            .observeSingleEvent(of: .value) {
                snapshot in
                
                self.chatModel.removeAll()
                print(self.chatModel.count,4333)
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot]  {
                    if snapshot.count == 0 {
                        self.firstAlertLabel.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        self.firstAlertLabel.isHidden = true
                        self.tableView.isHidden = false
                        
                        for id in snapshot {
                            
                            if let chatRoomdic = id.value as? [String:AnyObject] {
                                guard let chatModel = ChatModel(JSON: chatRoomdic) else { return }
                                self.chatModel.append(chatModel)
                                if self.chatModel.count == snapshot.count {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
        }
    }
    
}

extension DidChatMembersList:  UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DidChatMembersCell",for: indexPath) as? DidChatMembersCell else { return UITableViewCell()}
        cell.backgroundColor = .white
        var yourUID : String?
        let currentUID = appDelegate.currentUID ?? ""
        for i in chatModel[indexPath.row].users {
            if i.key != currentUID {
                yourUID = i.key
                guard let yourUid = yourUID else { return UITableViewCell() }
                self.yourUIDs.append(yourUid)
            }
        }
        
        if let yourUID = yourUID {
            firestoreRef
                .collection("user")
                .document("\(yourUID)")
                .getDocument { yourData, error in
                    guard let yourData = yourData?.data() else { return }
                    
                    let lastMessageKey = self.chatModel[indexPath.row].comments.keys.sorted(){ $0 > $1}
                    let userModel = YourData(userName: yourData["nickName"] as? String,
                                             userThumbnail: yourData["profileImageURL"] as? String,
                                             userUID: yourData["uid"] as? String)
                    
                    cell.nickName.text = userModel.userName
                    cell.lastMessageLabel.text = self.chatModel[indexPath.row].comments[lastMessageKey[0]]?.message
                    
                    if let time = self.chatModel[indexPath.row].comments[lastMessageKey[0]]?.timeStamp {
                        cell.timeStampLabel.text = time.toDayTime
                    }
                    
                    DispatchQueue.main.async {
                        guard let imageUrl = userModel.userThumbnail else { return }
                        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2
                        cell.profileImageView.layer.masksToBounds = true
                        cell.profileImageView.sd_setImage(with: URL(string: imageUrl))
                    }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
        let yourUID = yourUIDs[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChattingRoomViewController") as? ChattingRoomViewController else { return }
        vc.yourUID = yourUID
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}


