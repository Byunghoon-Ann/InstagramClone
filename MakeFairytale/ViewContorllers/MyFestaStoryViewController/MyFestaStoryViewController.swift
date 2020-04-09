//
//  MyFestaStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2019/10/15.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: 코드 출처 : 이동건의 이유있는 코드 https://baked-corn.tistory.com/111 에서 발췌 & 수정
import Foundation
import UIKit
import SDWebImage
import Firebase
import MobileCoreServices

fileprivate let databaseRef = Database.database().reference()
fileprivate let firestoreRef = Firestore.firestore()

class MyFestaStoryViewController: UIViewController, MyFestaStoryMenuViewDelegate,
MyViewsDelegate, MyPostTableViewDelegate, DidChattingCustomViewDelegate{
    
    @IBOutlet weak var FakeBarButton: UIButton!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myProfileName: UILabel!
    @IBOutlet var myPostFollowDataCount: [UILabel]!
    @IBOutlet var fixMyInfomation: UIButton!
    @IBOutlet weak var checkFollowButton: UIButton!
    
    var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let dateFomatter : DateFormatter = {
       let dateFomatter = DateFormatter()
       dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFomatter.locale = Locale(identifier: "kr_KR")
       return dateFomatter
    }()
    
    var alertLabel : UILabel = {
        let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 2
      label.font = .boldSystemFont(ofSize: 20)
      label.textColor = .black
      label.text =  "타인의 채팅기록은 조회할 수 없습니다."
      label.textAlignment = .center
      return label
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var myData: MyProfile?
    var customMenuBar = MyFestaStoryMenuView()
    var firstMyView = MyViews()
    var secondMyview = MyPostTableView()
    var thirdMyView = DidChattingCustomView()
    var myUID : String?
    var today = Date()
    var yourName: String = ""
    var followingCheck : [String] = []
    var followerCheck : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        setupPageCollectionView()
        myProfileName.text = yourName
        thirdMyView.tableViews.reloadData()
        pageCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstMyView.yourUID == "" || firstMyView
            .yourUID == appDelegate.currentUID{
            checkFollowButton.isHidden = true
        }else {
            checkFollowButton.isHidden = false
        }
        loadFollowCount()
        viewUserProfile {
            self.firstMyView.collectionView.reloadData()
        }
        myProfileImage.layer.cornerRadius = myProfileImage.bounds.height/2
        checkFollow()
    }
    
    //FIXME: 수정필요
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        firstMyView.yourUID = ""
//        secondMyview.yourUID = ""
    }
    
    //MARK: Following,UnFollow Button
    @IBAction func checkFollowButton(_ sender: Any) {
        followingCheckButton(checkFollowButton,
                             dateFomatter,
                             appDelegate,
                             secondMyview)
    }
    
    @IBAction func FakeBarButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: 프로필 수정 화면 이동 버튼
    @IBAction func fixMyInfomation(_ sender: Any) {
        guard let myProfileView = storyboard?.instantiateViewController(withIdentifier: "MyStoryViewController") else { return }
        navigationController?.pushViewController(myProfileView, animated: true)
    }
    
    func setupCustomTabBar() {
        self.view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        customMenuBar.indicatorViewWidthConstraint.constant = self.view.frame.width / 3
        customMenuBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        customMenuBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        customMenuBar.topAnchor.constraint(equalTo: self.view.topAnchor,constant: self.view.frame.height / 4).isActive = true
        customMenuBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func setupPageCollectionView() {
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.backgroundColor = .gray
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.register(UINib(nibName: "MyFestaStoryPageCell", bundle: nil), forCellWithReuseIdentifier: "MyFestaStoryPageCell")
        view.addSubview(pageCollectionView)
        
        pageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pageCollectionView.topAnchor.constraint(equalTo: self.customMenuBar.bottomAnchor,constant: 5).isActive = true
    }
    
    //MARK: Posting collectionView didSelectDelegate
    func customMyPostDidselect(_ path: Int) {
        moveDetailViewPostView(firstMyView,path)
    }
    
    func customMyPostTableDidselect(_ path: Int) {
        moveDetailViewPostView(firstMyView,path)
    }
    
    //MARK: MydidChattingList DIdSelectDelegate
    func customMyChatDidselect(_ path: Int) {
        let i = IndexPath(row:path,section:0)
        let yourUID = thirdMyView.chatModel[i.row]
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChattingRoomViewController") as? ChattingRoomViewController else { return }
        vc.yourUID = thirdMyView.yourUIDs[i.row]
        print(yourUID)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: Custom Tab Bar View Layout
extension MyFestaStoryViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyFestaStoryPageCell", for: indexPath) as? MyFestaStoryPageCell
            else { return UICollectionViewCell()}
        customInsertContentView(cell,indexPath)
        return cell
    }
    
    //MARK: CustomMenuBar에 indexPath를 받아서 didscroll로 pageViewCollection cell의 view화면과 이동을 구현
    func customMenuBar(scrollTo Index: Int) {
        let indexPath = IndexPath(row: Index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customMenuBar.indicatorViewLeadingConstraint.constant = scrollView.contentOffset.x / 3
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt,section: 0)
        customMenuBar.customTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}

extension MyFestaStoryViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MyFestaStoryViewController {
    func customInsertContentView(_ cell: UICollectionViewCell, _ indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.addSubview(firstMyView)
            firstMyView.translatesAutoresizingMaskIntoConstraints = false
            firstMyView.delegate = self
            firstMyView.isUserInteractionEnabled = true
            firstMyView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            firstMyView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            firstMyView.topAnchor.constraint(equalTo:cell.contentView.topAnchor).isActive = true
            firstMyView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor ).isActive = true
        } else if indexPath.row == 1 {
            cell.addSubview(secondMyview)
            secondMyview.translatesAutoresizingMaskIntoConstraints = false
            secondMyview.delegate = self
            secondMyview.isUserInteractionEnabled = true
            secondMyview.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            secondMyview.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            secondMyview.topAnchor.constraint(equalTo:cell.contentView.topAnchor).isActive = true
            secondMyview.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor ).isActive = true
        } else if indexPath.row == 2 {
            if firstMyView.yourUID == "" {
                alertLabel.isHidden = true
                cell.addSubview(thirdMyView)
                thirdMyView.translatesAutoresizingMaskIntoConstraints = false
                thirdMyView.delegate = self
                thirdMyView.isUserInteractionEnabled = true
                thirdMyView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
                thirdMyView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
                thirdMyView.topAnchor.constraint(equalTo:cell.contentView.topAnchor).isActive = true
                thirdMyView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor ).isActive = true
            } else {
                alertLabel.isHidden = false
                cell.addSubview(alertLabel)
                alertLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                alertLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            }
        }
    }
    
    func loadFollowCount() {
        followingCheck.removeAll()
        followerCheck.removeAll()
        guard let currentUID = appDelegate.currentUID else { return }
        let firestoreFollowRef = firestoreRef.collection("Follow")
        if secondMyview.yourUID != "" {
            firestoreFollowRef
                .document("\(secondMyview.yourUID)")
                .collection("FollowList")
                .getDocuments { snapshot,error in
                    
                    guard let snapshot = snapshot?.documents else { return }
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    self.myPostFollowDataCount[2].text = "\(self.followingCheck.count)"
            }
            
            firestoreRef
                .collection("Follower")
                .document("\(secondMyview.yourUID)")
                .collection("FollowerList")
                .getDocuments{ snapshot , error in
                    guard let snapshot = snapshot?.documents else {return}
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    self.myPostFollowDataCount[1].text = "\(self.followerCheck.count)"
            }
        } else {
            firestoreRef
                .collection("Follower")
                .document("\(currentUID)")
                .collection("FollowerList")
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot?.documents else {return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followerCheck.append(uid)
                    }
                    self.myPostFollowDataCount[1].text = "\(self.followerCheck.count)"
            }
            
            firestoreFollowRef
                .document("\(currentUID)")
                .collection("FollowList")
                .getDocuments { snapshot,error in
                    guard let snapshot = snapshot?.documents else{return}
                    
                    for i in snapshot {
                        let data = i.data()
                        let uid = data["uid"] as? String ?? ""
                        self.followingCheck.append(uid)
                    }
                    self.myPostFollowDataCount[2].text = "\(self.followingCheck.count)"
            }
        }
    }
    
    //MARK:- 사용자 혹은 타인의 프로필 조회시 발생하는 구별기능
    func viewUserProfile(completion : @escaping () -> Void) {
        guard let currentUID = appDelegate.currentUID else { return }
        FakeBarButton.isHidden = true
        
        if !firstMyView.yourUID.isEmpty, !secondMyview.yourUID.isEmpty {
            FakeBarButton.isHidden = false
            fixMyInfomation.isUserInteractionEnabled = false
            fixMyInfomation.isHidden = true
           
                firestoreRef
                    .collection("user")
                    .document("\(firstMyView.yourUID)")
                    .getDocument() { userData, error in
                        if let error = error { print("profileLoadError! \(error.localizedDescription)") }
                        guard let userData = userData?.data() else { return }
                         let userThumbnail = userData["profileImageURL"] as? String ?? ""
                         let nickName = userData["nickName"] as? String ?? ""
            
                        self.myProfileName.text = nickName
                        self.myProfileImage.sd_setImage(with: URL(string: userThumbnail))
                }
            
            firestoreRef.collection("AllPost").order(by: firstMyView.yourUID).getDocuments { (query, error) in
                if let error = error {print("\(error.localizedDescription)") }
                if query?.isEmpty == true {
                    self.myPostFollowDataCount[0].text = "0"
                    completion()
                } else {
                guard let query = query?.documents else { return }
                
                for document in query {
                    
                    guard let data = document.data() as? [String:[String:Any]] else { return }
                    let dataID = document.documentID
                    
                    firestoreRef
                        .collection("AllPost")
                        .document(dataID)
                        .collection("ViewCheck")
                        .getDocuments { viewCheck,error in
                            
                            firestoreRef
                                .collection("AllPost")
                                .document(dataID)
                                .collection("goodMarkLog")
                                .getDocuments { likeCount, error in
                                    
                                    for (_,j) in data {
                                        var viewCount = 0
                                        var likeCounts = 0
                                        
                                        let name = j["nickName"] as? String ?? ""
                                        let postComment = j["postComment"] as? String  ?? ""
                                        let postImageURL = j["postImageURL"] as? [String]  ?? [""]
                                        let date = j["date"] as? String  ?? ""
                                        let goodMark = j["goodMark"] as? Bool ?? false
                                        let profile = j["profileImageURL"] as? String  ?? ""
                                        let uid = j["uid"] as? String  ?? ""
                                       
                                        if let viewCheck = viewCheck {
                                            viewCount = viewCheck.count
                                        }
                                        
                                        if let likeCount = likeCount?.documents {
                                            for check in likeCount {
                                                let like = check["like"] as? Bool ?? false
                                                if like == true {
                                                    likeCounts += 1
                                                }
                                            }
                                        }
                                        
                                        self.firstMyView.myPosts.append(Posts(userUID: uid,
                                                                              userName: name,
                                                                              userComment: postComment,
                                                                              userProfileImage: profile,
                                                                              userPostImage: postImageURL,
                                                                              postDate: date,
                                                                              goodMark: goodMark,
                                                                              viewCount: viewCount,
                                                                              likeCount: likeCounts,
                                                                              urlkey:dataID))
                                        
                                        self.secondMyview.yourData.append(Posts(userUID: uid,
                                                                                userName: name,
                                                                                userComment: postComment,
                                                                                userProfileImage: profile,
                                                                                userPostImage: postImageURL,
                                                                                postDate: date,
                                                                                goodMark: goodMark,
                                                                                viewCount: viewCount,
                                                                                likeCount: likeCounts,
                                                                                urlkey:dataID))
                                        if query.count == self.firstMyView.myPosts.count,
                                            query.count == self.secondMyview.yourData.count  {
                                            
                                            self.secondMyview.tableView.reloadData()
                                            self.firstMyView.collectionView.reloadData()
                                            self.myPostFollowDataCount[0].text = "\(self.firstMyView.myPosts.count)"
                                            completion()
                                        }
                                        
                                    }
                            }
                    }
                    }
                    completion()
                }
            }
        } else {
            firstMyView.myPosts.removeAll()
            secondMyview.yourData.removeAll()
            firstMyView.myPosts = appDelegate.myPost
            secondMyview.yourData = appDelegate.myPost
            myData = appDelegate.myProfile
            firstMyView.collectionView.reloadData()
            secondMyview.tableView.reloadData()
            
            LoadFile.shread.getChatRoomLists {
                self.thirdMyView.chatModel.removeAll()
                self.thirdMyView.chatModel = LoadFile.shread.chatModel
                self.thirdMyView.tableViews.reloadData()
            }
            
            firestoreRef
                .collection("user")
                .document("\(currentUID)")
                .getDocument() { snapshot, error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        
                        guard let snapshot = snapshot?.data() else {return}
                        let nickName = snapshot["nickName"] as? String ?? ""
                        let email = snapshot["email"] as? String ??  ""
                        let profileImage = snapshot["profileImageURL"] as? String  ?? ""
                        self.myData = MyProfile(profileImageURL: profileImage, email: email, nickName: nickName, uid: currentUID)
                        guard let myData = self.myData else { return }
                        self.myProfileName.text = myData.nickName
                        self.myProfileImage.sd_setImage(with: URL(string: myData.profileImageURL))
                        completion()
                    }
            }
            self.myPostFollowDataCount[0].text = "\(self.firstMyView.myPosts.count)"
        }
    }
    
    func checkFollow() {
        guard let currentUID = appDelegate.currentUID else { return }
        let secondUID = secondMyview.yourUID
        if self.secondMyview.yourUID != "" {
            firestoreRef.collection("Follow")
                .document("\(currentUID)")
                .collection("FollowList")
                .document(secondUID)
                .getDocument { (snapshot, error) in
                    guard let snapshot = snapshot?.data() else{
                        self.checkFollowButton.isSelected = false
                        return }
                    
                    guard let follow = snapshot["follow"] as? Bool else {
                        self.checkFollowButton.isSelected = false
                        return
                    }
                    self.checkFollowButton.isSelected = follow
            }
        }
    }
}
