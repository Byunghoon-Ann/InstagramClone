//
//  PlusCommentViewContrller.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 03/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

//댓글창 ListViewController에서 댓글 선택시 보여준다
//맨 위는 해당 댓글의 계정주 그밑에는 단 사람 순서대로 나열, 뷰 맨 아래에 사용자가 댓글을 남길수 있고 남기면
//맨 마지막에 댓글이 달린다.
import Foundation
import UIKit
import Firebase
fileprivate let currentUID = Auth.auth().currentUser?.uid
fileprivate let firestoreRef = Firestore.firestore()

class PlusCommentViewContrller : UIViewController {
    @IBOutlet weak var nsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImgView: UIImageView!     //게시글 주인 프로필이미지뷰
    @IBOutlet weak var profileComment: UILabel!    //게시글 주인의 글
    @IBOutlet weak var commentTableView: UITableView!    //댓글테이블뷰
    @IBOutlet weak var checkUIBtn: UIButton! //댓글입력 버튼
    @IBOutlet weak var plusCommentTextField: UITextField!
    @IBOutlet weak var mySelfImgView: UIImageView!
    
    let alertLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "댓글이 아직 없습니다"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateFomatter : DateFormatter = {
       let dateFomatter = DateFormatter()
       dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFomatter.locale = Locale(identifier: "kr_KR")
       return dateFomatter
    }()
    
    let date = Date()
    var postKey : String = ""
    var postData: Posts?
    var myData : MyProfile?
    var repleData : [RepleData] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customAlertLabel()
        dataControl()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        plusCommentTextField.delegate = self
       
        commentTableView.layer.borderWidth = 0.3
        commentTableView.layer.borderColor = UIColor.gray.cgColor
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        mySelfImgView.layer.cornerRadius = mySelfImgView.frame.height/2
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismisskeyboard))
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
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.nsBottomConstraint.constant = keyboardSize.height
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        },completion: { complete in
            if self.repleData.count > 0 {
                self.commentTableView.scrollToRow(at: IndexPath(item: self.repleData.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.nsBottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismisskeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func backMainVCButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //댓글버튼입력 
    @IBAction func checkBtn(_ sender: Any) {
        guard let reple = plusCommentTextField.text else { return }
        let repleDate = dateFomatter.string(from: date)
        guard let post = postData else { return }
        let message = "님이 게시물에 댓글을 작성하셨습니다."
        if let currentUid = currentUID, let myData = myData {
            firestoreRef
                .collection("AllPost")
                .document(postKey)
                .collection("repleList")
                .addDocument(data: ["uid":currentUid,
                                    "profileImageURL":myData.profileImageURL,
                                    "reple":reple,
                                    "nickName":myData.nickName,
                                    "repleDate":repleDate])
            self.appDelegate.otherUID = currentUID
            self.notificationAlert(myData.nickName,
                                   repleDate,
                                   myData.uid,
                                   post.userUID,
                                   message,
                                   postKey)
            
            self.alertContentsCenter("reple",
                                     post.userUID)
            
            loadPostRepleData {
                self.commentTableView.reloadData()
            }
        }
    }
    
    func loadPostRepleData(completion : @escaping () -> Void) {
        self.repleData.removeAll()
        guard let postData = postData else { return }
        DispatchQueue.main.async {
            firestoreRef
                .collection("AllPost")
                .order(by:"\(postData.userUID)")
                .getDocuments { postList, error in
                    guard let postList = postList?.documents else {return}
                    for docment in postList {
                        guard let data = docment.data() as? [String:[String:Any]] else { return }
                        for (_,i) in data {
                            guard let date = i["date"] as? String else { return }
                            guard let postImageURL = i["postImageURL"] as? [String] else { return }
                            
                            if postData.postDate == date, postData.userPostImage == postImageURL {
                                let docKey = docment.documentID
                                
                                self.postKey = docKey
                                firestoreRef
                                    .collection("AllPost")
                                    .document(docKey)
                                    .collection("repleList")
                                    .getDocuments { snapshot, error in
                                        
                                        guard let snapshot = snapshot?.documents else { return }
                                        
                                        for i in snapshot {
                                            let repleData = i.data()
                                            guard let profile = repleData["profileImageURL"] as? String else { return }
                                            guard let uid = repleData["uid"] as? String else { return }
                                            guard let reple = repleData["reple"] as? String else { return }
                                            guard let nickName = repleData["nickName"] as? String else { return }
                                            let repleDate = repleData["repleDate"] as? String ?? ""
                                            self.repleData.append(RepleData(uid: uid,
                                                                            userThumbnail: profile,
                                                                            userReple: reple,
                                                                            nickName:nickName,
                                                                            repleDate: repleDate ))
                                        }
                                        if snapshot.count == self.repleData.count {
                                            
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

extension PlusCommentViewContrller : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = commentTableView.dequeueReusableCell(withIdentifier: "pluscommentcell") as? PlusCommentCell else { return  UITableViewCell()}
        cell.contentView.layer.borderWidth = 0.1
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.userThumbnail.layer.cornerRadius = cell.userThumbnail.frame.height/2
        cell.postUser.text = repleData[indexPath.row].userReple
        cell.userName.text = repleData[indexPath.row].nickName
        cell.userThumbnail.sd_setImage(with: URL(string: repleData[indexPath.row].userThumbnail))
        return cell
    }
}

extension PlusCommentViewContrller : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension PlusCommentViewContrller: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "댓글입력칸" {
            textField.text = ""
        }
        textField.becomeFirstResponder()
    }
}

extension PlusCommentViewContrller {
    func customAlertLabel() {
        view.addSubview(alertLabel)
        alertLabel.isHidden = true
        alertLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        alertLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    func dataControl() {
        loadPostRepleData {
            if self.repleData.isEmpty {
                self.commentTableView.isHidden = true
                self.alertLabel.isHidden  = false
            }
            self.repleData.sort { firstData, secondData in
                let dateFirstData = self.dateFomatter.date(from: firstData.repleDate) ?? self.date
                let dateSecondData = self.dateFomatter.date(from: secondData.repleDate) ?? self.date
                if dateFirstData > dateSecondData {
                    return true
                }else {
                    return false
                }
            }
            
            self.myData = self.appDelegate.myProfile
            guard let postData = self.postData else { return  }
            guard let myData = self.myData else{ return }
            
            self.profileImgView.sd_setImage(with: URL(string: postData.userProfileImage))
            self.profileComment.text = postData.userName
            self.mySelfImgView.sd_setImage(with: URL(string: myData.profileImageURL))
            
            self.commentTableView.reloadData()
        }
    }
}
