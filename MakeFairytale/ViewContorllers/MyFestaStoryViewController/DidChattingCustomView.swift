//
//  DidChattingCustomView.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/11/05.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: section 2
import UIKit
import SDWebImage
import Firebase

fileprivate let databaseRef = Database.database().reference()
fileprivate let firestoreRef = Firestore.firestore()

//MARK: DidChattingCustomView Delegate함수
protocol DidChattingCustomViewDelegate : class {
    func customMyChatDidselect(_ path: Int)
}

class DidChattingCustomView: UIView {
    
    weak var delegate : DidChattingCustomViewDelegate?
    var firstAlertLabel : UILabel = {
       let label = UILabel()
       label.translatesAutoresizingMaskIntoConstraints = false
       label.numberOfLines = 0
       label.font = .boldSystemFont(ofSize: 20)
       label.textColor = .black
       label.text = "대회기록이 존재하지 않습니다."
       label.textAlignment = .center
       return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setUpCustomMyChatList()
        firstAlertLabel.isHidden = true
        self.addSubview(firstAlertLabel)
        firstAlertLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        firstAlertLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var yourUIDs : [String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var chatModel: [ChatModel] = []
    var tableViews: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    func customCollections() {
        self.backgroundColor = .white
        tableViews.delegate = self
        tableViews.dataSource = self
        tableViews.register(UINib(nibName: "DidChattingCustomView", bundle: nil), forCellReuseIdentifier: "DidChattingCustomCell")
    }
    
    func setUpCustomMyChatList() {
        customCollections()
        self.addSubview(tableViews)
        tableViews.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableViews.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        tableViews.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableViews.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        tableViews.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableViews.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

//MARK: CustomChatList TableViewDataSource, Delegate
extension DidChattingCustomView : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatModel.isEmpty {
            tableViews.isHidden = true
            firstAlertLabel.isHidden = false
            return 0
        }else {
            tableViews.isHidden = false
            firstAlertLabel.isHidden = true
            return chatModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.item < chatModel.count else { return UITableViewCell() }
        let cell:DidChattingCustomCell = tableView.dequeueCell(indexPath: indexPath)
        var yourUID = ""
        let currentUID = appDelegate.currentUID ?? ""
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        for i in chatModel[indexPath.row].users {
            if i.key != currentUID {
                yourUID = i.key
                yourUIDs.append(yourUID)
                //self.yourUIDs.append(yourUid)
            }
        }
        
        guard !yourUID.isEmpty else { return UITableViewCell() }
        firestoreRef
            .collection("user")
            .document("\(yourUID)")
            .getDocument { snapshot, error in
                guard let snapshots = snapshot?.data() else { return }
                
                let userModel = YourData(userName: snapshots["nickName"] as? String,
                                         userThumbnail: snapshots["profileImageURL"] as? String,
                                         userUID: snapshots["uid"] as? String)
                
                cell.nickNameLabel.text = userModel.userName
                
                let lastMessageKey = self.chatModel[indexPath.row].comments.keys.sorted(){ $0 > $1}
                cell.lastMessage.text = self.chatModel[indexPath.row].comments[lastMessageKey[0]]?.message
                
                if let time = self.chatModel[indexPath.row].comments[lastMessageKey[0]]?.timeStamp {
                    cell.timeStamps.text = time.toDayTime
                }
                guard let imageUrl = userModel.userThumbnail else { return }
                cell.profileImageview.sd_setImage(with: URL(string: imageUrl))
        }
        
        return cell
    }
    
    //MARK:didSelectRowAt Delegate로 빼내기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.customMyChatDidselect(indexPath.row)
    }
    
    ///임시 TableView 높이 값 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}



