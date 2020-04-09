//
//  ListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 03/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//로그인 후 나타나는 뷰 페뷱이나 인스타처럼 팔로우한 사람들과 본인이 작성한 글들이 나타난다.
//noti넣을곳넣기
//MARK: TapBarIndex = 0, ViewController
import UIKit
import UserNotifications
import Firebase
import SDWebImage
import MobileCoreServices

fileprivate let firestoreRef = Firestore.firestore()

final class ListViewController : UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DropDownButtonDelegate {

   @IBOutlet weak var topUIView: UIView!
   @IBOutlet weak var topView: UIView!
   @IBOutlet weak var tableViewNSLayoutConstraint: NSLayoutConstraint!
   @IBOutlet weak var alertBadgeImageView: UIImageView!
   @IBOutlet weak var userProfileImageView: UIImageView! //사용자의 프로필 이미지뷰
   @IBOutlet weak var userProfileName: UILabel! // 사용자의 프로필 닉네임
   @IBOutlet weak var follwingCollectionView: UICollectionView!//팔로잉콜렉션뷰
   @IBOutlet weak var postTableView: UITableView!  //게시글 테이블뷰
   @IBOutlet weak var postLoadingIndicatior : UIActivityIndicatorView! // 데이터 로딩 인디게이터
   
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
   let date = Date()
   var leftTopButton = DropDownButton()
   var goodMarkURLKey : String = ""
   var festaData : [Posts] = [] // 포스팅 데이터
   var following : [FollowData] = [] //팔로잉 리스트
   var myProfileData: MyProfile?
   var topViewHideCheck = false
   var flagImageSave = false
   let imagePicker = UIImagePickerController()
   let refresh = UIRefreshControl()
   let dateFomatter : DateFormatter = {
      let dateFomatter = DateFormatter()
      dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      dateFomatter.locale = Locale(identifier: "kr_KR")
      return dateFomatter
   }()
   
   var firstAlertLabel : UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 0
      label.font = .boldSystemFont(ofSize: 20)
      label.textColor = .black
      label.text = "처음 사용이신 분들은 \n페스타 찾기 버튼을 클릭하셔서\n 페스타님들의 게시물을 구경해보세요! "
      label.textAlignment = .center
      return label
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
         print(didAllow)
      })
      
      UNUserNotificationCenter.current().delegate = self
      loadFesta(userProfileImageView,
                userProfileName,
                postLoadingIndicatior,
                postTableView,
                date,
                dateFomatter)
      
      initRefresh(refresh)
      
      let nibName = UINib(nibName: "FeedCollectionCell" , bundle: nil)
      postTableView.register(nibName, forCellReuseIdentifier: "feedcell")
      postTableView.layer.borderWidth = 0.2
      postTableView.layer.borderColor = UIColor.lightGray.cgColor
      alertBadgeImageView.isHidden = true
      postTableView.backgroundColor = .white
      view.backgroundColor = .white
      postTableView.dataSource = self
      postTableView.delegate = self
      follwingCollectionView.delegate = self
      follwingCollectionView.dataSource = self
      appDelegate.topViewHeight = Double(topView.frame.height)
      dropDownButtonSet()
      topViewHideSwipeGesture(postTableView)
      
      view.addSubview(firstAlertLabel)
      firstAlertLabel.isHidden = true
      firstAlertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      firstAlertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
   }
   
   //MARK: viewWillAppear
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      checknotificationCenter()
   }

   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      follwingCollectionView.collectionViewLayout = layout
      alertBadgeImageView.layer.cornerRadius = alertBadgeImageView.frame.height/2
      userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height/2
   }
   
   @IBAction func clickCameraButton(_ sender: Any) {
      if(UIImagePickerController.isSourceTypeAvailable(.camera)){
         flagImageSave = true
         imagePicker.delegate = self
         imagePicker.sourceType = .camera
         imagePicker.mediaTypes = [kUTTypeImage as String]
         imagePicker.allowsEditing = false
         present(imagePicker, animated: true, completion: nil)
      }
   }
   
   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
   }
   
   func checknotificationCenter() {
      let currentUID = appDelegate.currentUID ?? ""
      LoadFile.shread.snapshotListenerCheckEvent(currentUID,
                                                 alertBadgeImageView,
                                                 ["like","reple","follow","newPost"])
      
      if appDelegate.checkNotificationCheck == true {
         alertBadgeImageView.isHidden = false
         firestoreRef
            .collection("user")
            .document(currentUID)
            .updateData(["newPost":false])
         
         loadFesta(userProfileImageView,
                   userProfileName,
                   postLoadingIndicatior,
                   postTableView,
                   date,
                   dateFomatter)
      }
   }
}

//MARK: FollowingListDelegate
extension ListViewController : UICollectionViewDataSource {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return following.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard following.count > 0 else { return UICollectionViewCell() }
      guard let cell = self.follwingCollectionView.dequeueReusableCell(withReuseIdentifier: "follwingcell", for: indexPath) as? ListFollwingCell else { return UICollectionViewCell() }
      cell.followingData = following[indexPath.row]
      return cell
   }
}

extension ListViewController : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      guard let currentUID = appDelegate.currentUID else { return }
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyFestaStoryViewController") as? MyFestaStoryViewController else { return }
      vc.firstMyView.myUID = currentUID
      vc.secondMyview.yourUID = following[indexPath.row].userUID
      vc.firstMyView.yourUID = following[indexPath.row].userUID
      vc.yourName = following[indexPath.row].userName
      navigationController?.pushViewController(vc, animated: true)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: self.userProfileImageView.frame.width, height: 71)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 15
   }
}

extension ListViewController : UITableViewDataSource , UITableViewDelegate{
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return festaData.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard festaData.count > 0 else { return UITableViewCell() }
      guard let myProfileData = myProfileData else { return UITableViewCell() }
      guard let cell = postTableView.dequeueReusableCell(withIdentifier: "feedcell",for: indexPath) as? FeedCollectionCell else { return UITableViewCell() }
      
      cell.festaData = festaData[indexPath.row]
      cell.myProfile = myProfileData
      adScrollImageView(cell.postImageScrollView,
                        festaData[indexPath.row], true)
      
      cell.goodBtn.addTarget(self, action: #selector(goodButtonCustom(sender:)), for: .touchUpInside)
      cell.moreOptionButton.addTarget(self, action: #selector(postOptionButton),for: .touchUpInside)
      cell.moveRepleButton.addTarget(self, action:#selector(moveRepleList(sender:)), for:.touchUpInside)
      cell.chattingButton.addTarget(self, action: #selector(moveChattingView), for: .touchUpInside)
      return cell
   }
   
   //MARK: TableView DidSelectRow
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let viewPostingVC = storyboard?.instantiateViewController(withIdentifier:"ViewPostingController") as? ViewPostingController else  { return }
      viewPostingVC.post = festaData[indexPath.row]
      viewPostingVC.postNumber = indexPath.row
      navigationController?.pushViewController(viewPostingVC, animated: true)
   }
   
   //MARK: 좋아요 기능
   @objc func goodButtonCustom(sender:UIButton) {
      guard let currentUID = appDelegate.currentUID else { return }
      let contentView = sender.superview
      guard let cell = contentView?.superview as? FeedCollectionCell else { return }
      guard let indexPath = postTableView.indexPath(for: cell) else { return }
      let likeCheckDate = dateFomatter.string(from: self.date)
      
      DispatchQueue.main.async {
         self.likeButtonAction(likeCheckDate,
                               self.festaData[indexPath.row],
                               cell.goodBtn,
                               currentUID) {
                                 if cell.goodBtn.isSelected == true {
                                    self.festaData[indexPath.row].goodMark = true
                                    self.festaData[indexPath.row].likeCount += 1
                                    cell.likeCountLabel.text = "\(self.festaData[indexPath.row].likeCount) 좋아요"
                                    return
                                 } else {
                                    self.festaData[indexPath.row].goodMark = false
                                    self.festaData[indexPath.row].likeCount -= 1
                                    cell.likeCountLabel.text = "\(self.festaData[indexPath.row].likeCount) 좋아요"
                                    return
                                 }
         }
      }
   }
   
   @objc func postOptionButton(_ sender: UIButton) {
      let contentView = sender.superview
      guard let cell = contentView?.superview as? FeedCollectionCell else { return }
      guard let indexPath = postTableView.indexPath(for: cell) else {return}
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewPostingController") as? ViewPostingController else { return }
      
      let alert = UIAlertController(title: nil,
                                    message: nil,
                                    preferredStyle: .actionSheet)
      let cancel = UIAlertAction(title: "취소", style: .cancel)
      let detailAction = UIAlertAction(title: "자세히 보기",
                                       style: .default) { _ in
                                          vc.post = self.festaData[indexPath.row]
                                          self.navigationController?.pushViewController(vc, animated: true)
      }
      let deleteAction = UIAlertAction(title: "삭제",
                                       style: .default) { _ in
                                          let deleteAlert = UIAlertController(title: "안내",
                                                                              message: "게시물을 삭제하시겠습니까?",
                                                                              preferredStyle: .alert)
                                          
                                          let cancel = UIAlertAction(title: "취소",
                                                                     style: .cancel)
                                          
                                          let okAction = UIAlertAction(title: "확인",
                                                                       style: .default) { _ in
                                                                        
                                                                        let postURL = self.festaData[indexPath.row]
                                                                        for i in 0 ..< postURL.userPostImage.count {
                                                                           Storage
                                                                              .storage()
                                                                              .reference(forURL: "\(postURL.userPostImage[i])")
                                                                              .delete { (error) in
                                                                                 if let error = error {
                                                                                    print("storage Error! = \(error.localizedDescription)")}
                                                                           }
                                                                        }
                                                                        
                                                                        firestoreRef
                                                                           .collection("AllPost")
                                                                           .document("\(postURL.urlkey)")
                                                                           .delete { error in
                                                                              if let error = error {
                                                                                 print("error = \(error.localizedDescription)") }
                                                                        }
                                                                        self.postTableView.beginUpdates()
                                                                        self.festaData.remove(at: indexPath.row)
                                                                        self.postTableView.deleteRows(at: [indexPath], with: .automatic)
                                                                        self.postTableView.endUpdates()
                                          }
                                          deleteAlert.addAction(cancel)
                                          deleteAlert.addAction(okAction)
                                          self.present(deleteAlert,animated: true)
      }
      let messageAlert = UIAlertAction(title: "쪽지 보내기",
                                       style: .default) { _ in
                                          self.moveChattingViewController(sender,
                                                                          self.postTableView,
                                                                          self.festaData)
      }
      if self.festaData[indexPath.row].userUID == appDelegate.currentUID {
         alert.addAction(deleteAction)
      }
      
      if festaData[indexPath.row].userUID != appDelegate.currentUID {
         alert.addAction(messageAlert)
      }
      alert.addAction(detailAction)
      alert.addAction(cancel)
      self.present(alert,animated: true)
   }
   
   @objc func moveRepleList(sender: UIButton) {
      let contentView = sender.superview
      guard let cell = contentView?.superview as? FeedCollectionCell else  { return }
      guard let indexPath = postTableView.indexPath(for: cell) else { return }
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "PlusCommentViewContrller") as? PlusCommentViewContrller else { return }
      vc.postData = festaData[indexPath.row]
      navigationController?.pushViewController(vc, animated: true)
   }
   
   @objc func moveChattingView(_ sender: UIButton) {
      moveChattingViewController(sender,
                                 postTableView,
                                 festaData)
   }
}

