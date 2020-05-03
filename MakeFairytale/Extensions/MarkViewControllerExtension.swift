//
//  MarkViewControllerExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/05/03.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
fileprivate let postRef = Firestore.firestore().posts
extension AlbumViewController {
    func searchIndex(_ seletedIndex:[Int],_ indexPath:Int) -> Int {
        var index = -1
        for i in 0 ... seletedIndex.count {
            if seletedIndex[i] == indexPath {
                index = i
                return index
            }
        }
        return index
    }
    
    func followPostAlert(_ follows:[String]) {
        if !follows.isEmpty {
            for i in 0..<follows.count {
                Firestore.firestore().alertContentsCenter("post", follows[i])
            }
        }
    }
    
    func followListLoad() {
        follows.removeAll()
        if FirebaseServices.shread.following.count > 0 {
            for i in 0..<FirebaseServices.shread.following.count {
                follows.append(FirebaseServices.shread.following[i].userUID)
            }
        }
    }
    
    func readyUploadRequest(_ comment: String, _ selectImages: [UIImage], _ indicator: UIActivityIndicatorView, completion: @escaping () -> (Void)) {
        if comment.isEmpty || comment == "입력할 내용" {
            let alert = UIAlertController(title: "내용", message: "게시물의 내용을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert,animated: true)
        } else {
            indicator.startAnimating()
            indicator.isHidden = false
            for i in 0..<selectImages.count {
                count += 1
                guard let imageData = selectImages[i].jpegData(compressionQuality: 0.5) else { return }
                images.append(imageData)
                
                if selectImages.count == images.count {
                    completion()
                }
            }
        }
    }
    
    func uploadPostData(_ comment: String, _ checkToday: String, _ dateKR: String, _ currentUID: User, _ email: String, _ myProfile: MyProfile, _ storageRef: StorageReference, _ indicator: UIActivityIndicatorView) {
        let postingTextAddress = "\(comment.count)" + checkToday
        for j in 0 ..< self.images.count {
        storageRef
            .child(postingTextAddress)
            .child("\(j)")
            .putData(images[j], metadata: nil) { [weak self] mata,error in
                guard let self = self else { return }
                if let error = error { print("\(error.localizedDescription)") }
                
                storageRef
                    .child(postingTextAddress)
                    .child("\(j)")
                    .downloadURL { (down, error) in
                        
                        if let error = error { print("\(error.localizedDescription)") }
                        
                        if let url = down?.absoluteString {
                            self.urlString.append(url)
                            
                        }
                        if self.urlString.count == self.selectedImages.count {
                            self.followPostAlert(self.follows)
                            
                            postRef
                                .addDocument(data: [currentUID.uid:[
                                    "uid":currentUID.uid,
                                    "profileImageURL":myProfile.profileImageURL,
                                    "postComment":comment,
                                    "email":email,
                                    "postImageURL":self.urlString,
                                    "goodMark":false,
                                    "nickName":myProfile.nickName,
                                    "date":"\(dateKR)"]]) { error in
                                        if let error = error { print("\(error.localizedDescription)")}
                                        indicator.stopAnimating()
                                        indicator.isHidden = true
                                        State.shread.autoRefreshingCheck = true
                                        self.tabBarController?.selectedIndex = 0
                            }
                        }
                }
            }
        }
    }
}
