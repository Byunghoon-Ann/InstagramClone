//
//  AlbumViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 04/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
import UIKit
import Firebase
import Photos
import AssetsLibrary

fileprivate let currentUID = Auth.auth().currentUser
fileprivate let fireStorageRef = Storage.storage().reference(forURL: "gs://festargram.appspot.com").child("myPost")
fileprivate let postRef = Firestore.firestore().posts
fileprivate let userRef = Firestore.firestore().user

class AlbumViewController : UIViewController, PhothAurhorizationStatus{
    
    @IBOutlet weak var sendingPostIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var commentInputText: UITextView!
    @IBOutlet weak var itemsSelectedButton: UIButton!
    @IBOutlet weak var alertImageCountLabel: UILabel!
    @IBOutlet weak var setPostingButton: UIButton!
    @IBOutlet weak var postingContentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var today = Today.shread.today
    lazy var dateFomatter = DateCalculation.shread.dateFomatter
   
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                for (key, value) in dictionarySelectedIndecPath {
                    if value {
                        collectionView.deselectItem(at: key, animated: true)
                    }
                }
                setPostingButton.isUserInteractionEnabled = false
                setPostingButton.alpha = 0.6
                alertImageCountLabel.isHidden = true
                collectionView.allowsSelection = true
                collectionView.allowsMultipleSelection = false
            case .select:
                alertImageCountLabel.isHidden = false
                collectionView.allowsMultipleSelection = true
            }
        }
    }
    
    var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return fetchOptions
    }()
    
    var images: [Data] = []
    var selectedImages : [UIImage] = []
    var fetchResult: PHFetchResult<PHAsset>?
    let imageManager = PHCachingImageManager()
    let TcgSize: CGSize = CGSize(width: 1024, height: 1024)
    let scale = UIScreen.main.scale
    var selectAsset: PHAsset?
    var dictionarySelectedIndecPath: [IndexPath: Bool] = [:]
    var selectedAssetIndex: [Int] = []
    var count = 0
    var urlString: [String] = []
    var follows: [String] = []
    var myProfile: MyProfile? {
        FirebaseServices.shread.myProfile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentInputText.delegate = self
        commentInputText.backgroundColor = .white
        sendingPostIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mMode = .view
        PHPhotoLibrary.shared().register(self)
        phothAurhorizationStatus()
        followListLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mMode = .view
        commentInputText.text = "입력할 내용"
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentInputText.resignFirstResponder()
    }
    
    @IBAction func didSelectButtonClicked(_ sender: Any) {
        if let _sender = sender as? UIButton {
            switch _sender.isSelected {
            case true:
                mMode = .view
                _sender.isSelected = false
                dictionarySelectedIndecPath.removeAll()
                selectedImages.removeAll()
                urlString.removeAll()
                selectedAssetIndex.removeAll()
            case false:
                _sender.isSelected = true
                mMode = .select
            }
        }
    }
    
    @IBAction func setPost(_ sender: Any) {
        guard let postingText = commentInputText.text else { return }
        
        readyUploadRequest(postingText,
                           selectedImages,
                           sendingPostIndicator ) { [weak self ] in
                            guard let self = self else { return  }
                            
                            let dateKR = self.dateFomatter.string(from: self.today)
                            let checkToday = self.dateFomatter.string(from: self.today)
                            
                            guard let currentUID = currentUID,
                                let email = currentUID.email,
                                let myProfile = self.myProfile else { return }
                            
                            let storageRef = fireStorageRef.child("\(currentUID.uid)").child("postingText")
                            self.uploadPostData(postingText,
                                                checkToday,
                                                dateKR,
                                                currentUID,
                                                email,
                                                myProfile,
                                                storageRef,
                                                self.sendingPostIndicator)
        }
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < fetchResult?.count ?? 0 else { return UICollectionViewCell() }
        let cell: MyAlbumCollectionCell = collectionView.dequeueCell(indexPath: indexPath)
        guard let asset = fetchResult?[indexPath.row] else { return UICollectionViewCell() }
        OperationQueue.main.addOperation {
            self.imageManager.requestImage(for: asset,
                                           targetSize: self.TcgSize,
                                           contentMode: .aspectFill,
                                           options: nil) { image, _ in
                                            cell.configure(with: image)
            }
        }
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = fetchResult?.object(at: indexPath.item) else { return }
        
        switch mMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            imageManager.requestImage(for: asset,
                                      targetSize: TcgSize,
                                      contentMode: .aspectFit,
                                      options: nil) { image, _ in
                                        guard let image = image else { return }
                                        self.selectedImg.image = image
            }
            
        case .select:
            dictionarySelectedIndecPath[indexPath] = true
            selectAsset = asset
            selectedAssetIndex.insert(indexPath.item, at: 0)
            
            imageManager.requestImage(for: asset,
                                      targetSize: TcgSize,
                                      contentMode: .aspectFit,
                                      options: nil) { image, _ in
                                        guard let image = image else { return }
                                        self.selectedImg.image = image
                                        self.selectedImages.insert(image, at: 0)
            }
            
            selectedImages.remove(at: 0)
            
            if selectedAssetIndex.count >= 1 {
                setPostingButton.alpha = 1.0
                setPostingButton.isUserInteractionEnabled = true
                alertImageCountLabel.text = "\(selectedAssetIndex.count)개 선택"
            }else {
                alertImageCountLabel.text = "선택 없음"
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectedAssetIndex.count >= 1, commentInputText.text.count >= 1 {
            setPostingButton.isUserInteractionEnabled = true
            setPostingButton.alpha = 1.0
        }else {
            setPostingButton.isUserInteractionEnabled = false
            setPostingButton.alpha = 0.6
        }
        
        if mMode == .select {
            dictionarySelectedIndecPath[indexPath] = false
            let index = searchIndex(selectedAssetIndex, indexPath.item)
            
            if index < 0 {
                print("out of indexpath out of range")
            }else {
                selectedAssetIndex.remove(at: index)
                selectedImages.remove(at: index)
                
                if selectedAssetIndex.count == 0 {
                    setPostingButton.isUserInteractionEnabled = false
                    setPostingButton.alpha = 0.6
                    alertImageCountLabel.text = "선택 없음"
                } else {
                    setPostingButton.isUserInteractionEnabled = true
                    setPostingButton.alpha = 1.0
                    alertImageCountLabel.text = "\(selectedAssetIndex.count)개 선택"
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3 - 1, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension AlbumViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        if textView.text == "입력할 내용" {
            textView.text = ""
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}

//MARK:- phasset Func
extension AlbumViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        OperationQueue.main.addOperation {
            guard let fetchResult = self.fetchResult else { return }
            if let changes = changeInstance.changeDetails(for: fetchResult) {
                self.fetchResult = changes.fetchResultAfterChanges
            }
        }
    }
    
    func requestImageCollection() {
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        for integer in 0 ..< cameraRoll.count {
            let collection = cameraRoll.object(at: integer)
            self.fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        }
        
        guard let fetchResult = fetchResult else { return }
        OperationQueue.main.addOperation {
            self.imageManager.requestImage(for: fetchResult.object(at: 0),
                                      targetSize: self.TcgSize,
                                      contentMode: .aspectFit,
                                      options: nil) { image, _ in
                                        self.selectedImg.image = image
            }
        }
    }
}
