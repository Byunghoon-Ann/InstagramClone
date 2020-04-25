//
//  ListViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 03/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//MARK: TapBarIndex = 0, ViewController
import UIKit
import UserNotifications
import Firebase
import SDWebImage
import MobileCoreServices

fileprivate let userRef = Firestore.firestore().user
fileprivate let postRef = Firestore.firestore().posts
final class ListViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DropDownButtonDelegate {

   @IBOutlet weak var topUIView: UIView!
   @IBOutlet weak var topView: UIView!
   @IBOutlet weak var tableViewNSLayoutConstraint: NSLayoutConstraint!
   @IBOutlet weak var alertBadgeImageView: UIImageView!
   @IBOutlet weak var userProfileImageView: UIImageView! //사용자의 프로필 이미지뷰
   @IBOutlet weak var userProfileName: UILabel! // 사용자의 프로필 닉네임
   @IBOutlet weak var follwingCollectionView: UICollectionView!//팔로잉콜렉션뷰
   @IBOutlet weak var postTableView: UITableView!  //게시글 테이블뷰
   @IBOutlet weak var postLoadingIndicatior : UIActivityIndicatorView! // 데이터 로딩 인디게이터
  
   lazy var leftTopButton = DropDownButton()
   lazy var dateFomatter = DateCalculation.shread.dateFomatter
   lazy var firstAlertLabel : UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 0
      label.font = .boldSystemFont(ofSize: 20)
      label.textColor = .black
      label.text = "처음 사용이신 분들은 \n페스타 찾기 버튼을 클릭하셔서\n 페스타님들의 게시물을 구경해보세요! "
      label.textAlignment = .center
      return label
   }()
   
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
   var festaData : [Posts] = [] {
      willSet {
         self.festaData.removeAll()
      } didSet {
         DateCalculation.shread.requestSort(&festaData,
                                            dateFomatter,
                                            Today.shread.today)
         postTableView.reloadData()
      }
   }
   
   var following : [FollowData] = [] {
      didSet {
         follwingCollectionView.reloadData()
      }
   }
   

   var myProfileData: MyProfile? {
      didSet {
         guard let myProfileData = myProfileData else { return }
         userProfileName.text = myProfileData.nickName
         userProfileImageView.sd_setImage(with: URL(string: myProfileData.profileImageURL))
      }
   }
   
   var goodMarkURLKey: String = ""
   var topViewHideCheck = false
   var flagImageSave = false
   let imagePicker = UIImagePickerController()
   let refresh = UIRefreshControl()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
         print(didAllow)
      })
      
      UNUserNotificationCenter.current().delegate = self
      loadFesta(postLoadingIndicatior,
                postTableView)
      
      initRefresh(refresh)
      
      postTableView.registerCell(FeedCollectionCell.self)
      
      postTableView.layer.borderWidth = 0.2
      postTableView.layer.borderColor = UIColor.lightGray.cgColor
      alertBadgeImageView.isHidden = true
      postTableView.backgroundColor = .white
      view.backgroundColor = .white
     
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
      FirebaseServices.shread.snapshotListenerCheckEvent(currentUID,
                                                         alertBadgeImageView,
                                                         ["like","reple","follow","newPost"])
      
      if State.shread.checkNotificationCheck == true {
         alertBadgeImageView.isHidden = false
         userRef
            .document(currentUID)
            .updateData(["newPost":false])
         
         loadFesta(postLoadingIndicatior,
                   postTableView)
      }
   }
}

//MARK: FollowingListDelegate
extension ListViewController : UICollectionViewDataSource {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      guard following.count > 0 else { return 0 }
      return following.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard indexPath.row < following.count else { return UICollectionViewCell() }
      let cell:ListFollwingCell = follwingCollectionView.dequeueCell(indexPath: indexPath)
      cell.followingData = following[indexPath.row]
      return cell
   }
}

extension ListViewController : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      guard let currentUID = appDelegate.currentUID else { return }
      guard let vc = UIStoryboard.myFestaStoryVC() else { return }
      
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
      guard indexPath.row < festaData.count else { return UITableViewCell() }
      guard let myProfileData = myProfileData else { return UITableViewCell() }
      let cell: FeedCollectionCell = tableView.dequeueCell(indexPath: indexPath)
      
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
      guard let vc = UIStoryboard.viewPostingVC() else { return }
      vc.post = festaData[indexPath.row]
      vc.postNumber = indexPath.row
      navigationController?.pushViewController(vc, animated: true)
   }
   
   //MARK: 좋아요 기능
   @objc func goodButtonCustom(sender:UIButton) {
      guard let currentUID = appDelegate.currentUID else { return }
      let contentView = sender.superview
      guard let cell = contentView?.superview as? FeedCollectionCell else { return }
      guard let indexPath = postTableView.indexPath(for: cell) else { return }
      let likeCheckDate = DateCalculation.shread.dateFomatter.string(from: appDelegate.date)
      
      DispatchQueue.main.async { [weak self] in
         guard let self = self else {  return }
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
      appDelegate.indexPath = indexPath
      CommonService.shread.orderSelect = .option
      presentAlert(.actionSheet)
   }
   
   @objc func moveRepleList(sender: UIButton) {
      let contentView = sender.superview
      guard let cell = contentView?.superview as? FeedCollectionCell else  { return }
      guard let indexPath = postTableView.indexPath(for: cell) else { return }
      guard let vc = UIStoryboard.plusCommentVC() else { return }
      vc.postData = festaData[indexPath.row]
      navigationController?.pushViewController(vc, animated: true)
   }
   
   @objc func moveChattingView(_ sender: UIButton) {
      moveChattingViewController(sender,
                                 postTableView,
                                 festaData)
   }
}

