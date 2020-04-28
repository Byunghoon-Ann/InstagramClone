//
//  ChattingRoomViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/29.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

fileprivate let firestoreRef = Firestore.firestore()
fileprivate let chatRoomRef = Database.database().reference().child("chatRooms")

class ChattingRoomViewController : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nsBottomConstrant: NSLayoutConstraint!
    @IBOutlet var textField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    var chatRoomUID  = ""
    var comments : [ChatModel.Comment] = []
    var userModel : YourData?
    var databaseRef: DatabaseReference?
    var observe : UInt?
    var peopleCount: Int?
    var yourUID:String? {
        return CurrentUID.shread.yourUID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.isUserInteractionEnabled = true
        sendButton.isUserInteractionEnabled = true
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        databaseRef?.removeObserver(withHandle: observe!)
    }
    
    @objc func createRoom() {
        guard let chatText = textField.text else {return}
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        guard let yourUID = CurrentUID.shread.yourUID else { return }

        let createRoomInfo : Dictionary<String,Any> =  [
            "users":[currentUID:true,
                     yourUID:true] ]
        if chatRoomUID.isEmpty {
            sendButton.isEnabled = false
            chatRoomRef
                .childByAutoId()
                .setValue(createRoomInfo) { error,ref in
                    if error == nil {
                        self.checkChatRoom()
                        let value : Dictionary<String,Any> = [
                            "uid":currentUID,
                            "message":chatText,
                            "timeStamp":ServerValue.timestamp()]
                        chatRoomRef
                            .child(self.chatRoomUID)
                            .child("comments")
                            .childByAutoId()
                            .setValue(value) { error,ref in
                                self.textField.text = ""
                                Firestore.firestore().alertContentsCenter("chatting", yourUID)
                        }
                    }
            }
        } else {
            
            let value : Dictionary<String,Any> = [
                "uid":currentUID,
                "message":chatText,
                "timeStamp":ServerValue.timestamp()]
           chatRoomRef
                .child(chatRoomUID)
                .child("comments")
                .childByAutoId()
                .setValue(value) { error,ref in
                    self.textField.text = ""
                    Firestore.firestore().alertContentsCenter("chatting",yourUID)
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.nsBottomConstrant.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0,animations:  {
            self.view.layoutIfNeeded()
        },completion: { complete in
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.nsBottomConstrant.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismisskeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:챗방중복생성방지 함수
    func checkChatRoom() {
        guard let currentUID = CurrentUID.shread.currentUID else  { return }
        guard let yourUID = CurrentUID.shread.yourUID else { return }
        chatRoomRef
            .queryOrdered(byChild: "users/"+currentUID)
            .queryEqual(toValue: true)
            .observe(.value) { snapshot in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                for id in snapshot {
                    
                    if let chatRoomdic = id.value as? [String:AnyObject] {
                        guard let chatModel = ChatModel(JSON: chatRoomdic) else { return }
                       
                        if chatModel.users[yourUID] == true {
                            self.chatRoomUID = id.key
                            self.sendButton.isEnabled = true
                            self.getYourInfo()
                        }
                    }
                }
        }
    }
    
    //MARK:사용자 정보 불러오기
    func getYourInfo() {
        guard let yourUID = CurrentUID.shread.yourUID else { return }

        firestoreRef
            .collection("user")
            .document("\(yourUID)")
            .getDocument { (yourData, error) in
                guard let yourData = yourData?.data() else {return}
                
                let nickname = yourData["nickName"] as? String
                let profile = yourData["profileImageURL"] as? String
                let data = YourData(userName: nickname, userThumbnail: profile)
                self.userModel = data
            self.getMessageList()
        }
        
    }
    
    //MARK:채팅기록 로드 함수
    func getMessageList() {
        guard let currentUID = CurrentUID.shread.currentUID else { return }
        databaseRef = chatRoomRef.child("\(chatRoomUID)").child("comments")
        observe = databaseRef?.observe(.value) { snapshot in
            
            self.comments.removeAll()
            var readUserDic: Dictionary<String,AnyObject> = [:]
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for id in snapshots {
                let key = id.key as String
                guard let idValue = id.value as? [String:AnyObject] else { return }
                guard let comment = ChatModel.Comment(JSON: idValue) else { return }
                guard let comment_Dic = ChatModel.Comment(JSON: idValue) else { return }
                
                comment_Dic.readUsers[currentUID] = true
                readUserDic[key] = comment_Dic.toJSON() as NSDictionary
                self.comments.append(comment)
            }
            
            let nsDic = readUserDic as NSDictionary
            guard let nsDics = nsDic as? [AnyHashable:Any] else { return }
            guard let keysContains = self.comments.last?.readUsers.keys.contains(currentUID) else { return }
            if !(keysContains) {
                
                snapshot
                    .ref
                    .updateChildValues(nsDics) { err,ref in
                    self.tableView.reloadData()
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
                
            } else {
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1,
                                                             section: 0),
                                               at: .bottom, animated: true)
                }}
        }
    }
    
    //MARK: 메세지 읽음 여부 함수
    func setReadBool(label: UILabel?,position: Int?) {
        let readBool = self.comments[position!].readUsers.count + 1
        if peopleCount == nil {
      //      guard let chatRoomUID = chatRoomUID else  {return }
            chatRoomRef
                .child("\(chatRoomUID)")
                .child("users")
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dic = snapshot.value as? [String:Any] else { return }
                    self.peopleCount = dic.count
                    
                    let noReadBoolCount = self.peopleCount! - readBool
                    
                    if noReadBoolCount > 0 {
                        label?.isHidden = false
                        label?.text = String(noReadBoolCount)
                    }else {
                        label?.isHidden = true
                    }}
        }else {
            guard let peopleCount = self.peopleCount else { return }
            
            let noReadBoolCount = peopleCount - readBool
            
            if noReadBoolCount > 0 {
                label?.isHidden = false
                label?.text = String(noReadBoolCount)
            }else {
                label?.isHidden = true
            }
        }
    }
}

extension ChattingRoomViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myData = FirebaseServices.shread.myProfile else { return UITableViewCell() }
        guard indexPath.row < comments.count else { return UITableViewCell() }
        if  comments[indexPath.row].uid  == CurrentUID.shread.currentUID {
            let cell:MyMessageCell = tableView.dequeueCell(indexPath: indexPath)
            
            cell.myMessageLabel.text = comments[indexPath.row].message
            cell.myThumbnail.sd_setImage(with: URL(string: myData.profileImageURL))
            cell.myNickName.text = myData.nickName
            cell.myMessageLabel.numberOfLines = 0
            
            if let time = self.comments[indexPath.row].timeStamp {
                cell.timeStampLabel.text = time.toDayTime
            }
            
            setReadBool(label: cell.readBoolLabel,
                        position: indexPath.row)
            return cell
        }else {
            let cell:YourMessageCell = tableView.dequeueCell(indexPath: indexPath)
            
            guard let userData = self.userModel else { return UITableViewCell() }
            guard let imageUrl = userData.userThumbnail else { return UITableViewCell() }
            cell.yourMessageCell.text = self.comments[indexPath.row].message
            cell.yourMessageCell.numberOfLines = 0
            cell.yourNickName.text = userData.userName
            cell.yourThumbnail.sd_setImage(with: URL(string: imageUrl))
            
            if let time = self.comments[indexPath.row].timeStamp {
                cell.timeStampLabel.text = time.toDayTime
            }
            
            setReadBool(label: cell.readBoolLabel, position: indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension Int {
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
}


/*//        switch comments[indexPath.row].uid {
//        case currentUID:
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell",for: indexPath) as! MyMessageCell
//            cell.myMessageLabel.text = comments[indexPath.row].message
//            cell.myMessageLabel.numberOfLines = 0
//
//            if let time = self.comments[indexPath.row].timeStamp {
//                cell.timeStampLabel.text = time.toDayTime
//            }
//
//            setReadBool(label: cell.readBoolLabel, position: indexPath.row)
//            return cell
//
//        case yourUID:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "YourMessageCell") as! YourMessageCell
//            DispatchQueue.main.async {
//
//                cell.yourMessageCell.text = self.comments[indexPath.row].message
//            cell.yourMessageCell.numberOfLines = 0
//                cell.yourNickName.text = self.userModel[indexPath.row].userName
//                cell.yourThumbnail.sd_setImage(with: URL(string: self.userModel[indexPath.row].userThumbnail))
//
//                self.setReadBool(label: cell.readBoolLabel, position: indexPath.row)
//            if let time = self.comments[indexPath.row].timeStamp {
//                cell.timeStampLabel.text = time.toDayTime
//            }
//            }
//            return cell
//        default:
//            return UITableViewCell()
//        }
//
//
//    }
//return UITableViewCell()*/
