//
//  MyStoryViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 04/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let firestoreRef = Firestore.firestore()
fileprivate let StorageRef = Storage.storage()
fileprivate let auth = Auth.auth().currentUser

class MyStoryViewController : UIViewController,UITextFieldDelegate {
    ///사용자 닉네임,비밀번호,이메일 표시, 수정 textField
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var updateProfile: UIButton!
    @IBOutlet weak var loadProfileIndicator: UIActivityIndicatorView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldBorderCustom(userNameTextField,
        userPassword,
        userEmail)
        firebaseFetch()
        
        userPassword.isSecureTextEntry = true
        
        let selectProfileImageGesture =  UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.addGestureRecognizer(selectProfileImageGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseFetch()
    }
 
    @IBAction func updateProfileButton(_ sender: Any) {
        selectimg(imagePicker)
    }
    
    @IBAction func popViewButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePasswordButton(_ sender: Any) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        let alert = UIAlertController(title: "안내",
                                      message: "비밀번호를 변경하시겠습니까?",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "네",
                                     style: .default) { _ in
                                        let msg = "변경하실 비밀번호를 입력해주세요. \n 비밀번호는 6자리 이상이어야 합니다"
                                        let alert = UIAlertController(title: "비밀번호 변경",
                                                                      message: msg,
                                                                      preferredStyle: .alert)
                                        
                                        let ok = UIAlertAction(title: "ok",
                                                               style: .default) { _ in
                                                                
                                                                guard let tfFirset = alert.textFields?[0].text ,
                                                                    let tfSecond = alert.textFields?[0].text else {
                                                                        return }
                                                                
                                                                if tfFirset == tfSecond && tfFirset.count >= 6 {
                                                                    firestoreRef
                                                                        .collection("user")
                                                                        .document(currentUID)
                                                                        .updateData(["password":tfFirset])
                                                                    
                                                                    Auth
                                                                        .auth()
                                                                        .currentUser?
                                                                        .updatePassword(to: tfFirset)
                                                                    
                                                                    let alert = UIAlertController(title: "성공",
                                                                                                  message: "비밀번호가 변경되었습니다.",
                                                                                                  preferredStyle: .alert)
                                                                    
                                        let ok = UIAlertAction(title: "ok",
                                                               style: .default)
                                        alert.addAction(ok)
                                        self.present(alert,animated: true)
                                    } else {
                                        
                                        let alert = UIAlertController(title: "에러",
                                                                      message: "입력하신 비밀번호가 6자리 이하이거나 \n 두 비밀번호가 일치하지 않습니다.",
                                                                      preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "ok",
                                                               style: .default)
                                        alert.addAction(ok)
                                        self.present(alert,animated: true)
                                    }
            }
            alert.addTextField { tf in
                tf.placeholder = "새로운 비밀번호"
            }
            alert.addTextField { tf in
                tf.placeholder = "비밀번호 확인"
            }
            alert.addAction(ok)
            self.present(alert,animated: true)
        }
        let cancel = UIAlertAction(title: "아니요", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
    
    
    @IBAction func saveMyProfileButton(_ sender: Any) {
        guard let nickNameText = userNameTextField.text else {return}
        guard let passwordText = userPassword.text else { return }
        let alert = UIAlertController(title: "프로필 변경",
                                      message: "이대로 저장하시겠습니까?",
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel)
        
        let ok = UIAlertAction(title: "네",
                               style: .default) { _ in
                                guard let currentUID = Auth.auth().currentUser else {return}
                                let storageRef = Storage.storage().reference(forURL: "gs://festargram.appspot.com/")
                                    .child("ProfileImage")
                                    .child("\(currentUID.uid)")
                                
                                guard let uploadImage =  self.profileImageView.image?.jpegData(compressionQuality: 0.5) else {return}
                                
                                storageRef.putData(uploadImage, metadata: nil) { download,error in
                                    if let error = error  { print("\(error.localizedDescription)") }
                                    storageRef.downloadURL { url, error in
                                        
                                        guard let url = url?.absoluteString else {return}
                                        firestoreRef
                                            .collection("user")
                                            .document(currentUID.uid)
                                            .setData(["nickName":nickNameText,
                                                      "profileImageURL":url,
                                                      "password": passwordText,
                                                      "email":currentUID.email,
                                                      "uid":currentUID.uid])
                                    }}
                                
                                let alert = UIAlertController(title: "비밀번호 변경" , message: "저장이 완료되었습니다!", preferredStyle: .alert)
                                
                                let ok = UIAlertAction(title: "확인", style: .default)
                                alert.addAction(ok)
                                self.present(alert,animated: true)
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
    
    @IBAction func idDeleteButton(_ sender: Any) {
        deleteIDEvent()
    }
    
    func firebaseFetch() {
        loadProfileIndicator.startAnimating()
        
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        firestoreRef
            .collection("user")
            .document("\(currentUID)")
            .getDocument {snapshot, error in
                
                guard let snapshot = snapshot?.data() else {return}
                let profile = snapshot["profileImageURL"] as? String ?? ""
                let nickName = snapshot["nickName"] as? String ?? ""
                let email = snapshot["email"] as? String ?? ""
                let password = snapshot["password"] as? String ?? ""
                
                self.profileImageView.sd_setImage(with: URL(string: profile))
                self.userNameTextField.text = nickName
                self.userEmail.text = email
                self.userPassword.text = password
                self.loadProfileIndicator.stopAnimating()
                self.loadProfileIndicator.isHidden = true
        }
    }
    
    @objc func selectProfileImage() {
        selectimg(imagePicker)
    }
    
    func deleteIDEvent() {
        guard let userEmailText = userEmail.text else { return }
        guard let passwordText = userPassword.text else { return }
        guard let auth = auth else { return }
        let credential = EmailAuthProvider.credential(withEmail: userEmailText,
                                                      password: passwordText)
        
        let alert = UIAlertController(title: "회원 탈퇴",
                                      message: "Festagram을 탈퇴하시겠습니까?",
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "네", style: .default) { _ in
            
            auth
                .reauthenticate(with: credential) { authentication, error in
                    if let error = error { print("인증 에러",error.localizedDescription) }
                    
                    firestoreRef
                        .collection("user")
                        .document(auth.uid)
                        .delete()
                    
                    auth.delete { error in
                        if let error = error { print("탈퇴 에러 = \(error.localizedDescription)")}
                    }
                    
                    let completeDeleteAlert = UIAlertController(title: "탈퇴 완료",
                                                                message: "이용해주셔서 감사합니다.",
                                                                preferredStyle: .alert)
                    
                    let completeDeleteAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    completeDeleteAlert.addAction(completeDeleteAction)
                    self.present(completeDeleteAlert,animated: true)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert,animated: true)
    }
}

extension MyStoryViewController {
    ///textField 커스텀 border 함수
    func textFieldBorderCustom(_ field1: UITextField,
                               _ field2: UITextField,
                               _ field3: UITextField) {
        
        field1.delegate = self
        field1.borderStyle = .none
        let border1 = CALayer()
        border1.backgroundColor = UIColor.black.cgColor
        border1.frame = CGRect(x: 0, y: field1.frame.size.height - 3, width: field1.frame.size.width, height: 1)
        field1.layer.addSublayer(border1)
        
        field2.delegate = self
        field2.borderStyle = .none
        let border2 = CALayer()
        border2.backgroundColor = UIColor.black.cgColor
        border2.frame = CGRect(x: 0, y: field2.frame.size.height - 3, width: field2.frame.size.width, height: 1)
        field2.layer.addSublayer(border2)
        
        field3.delegate = self
        field3.borderStyle = .none
        let border3 = CALayer()
        border3.backgroundColor = UIColor.black.cgColor
        border3.frame = CGRect(x: 0, y: field3.frame.size.height - 3, width: field3.frame.size.width, height: 1)
        field3.layer.addSublayer(border3)
    }
}

extension MyStoryViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        dismiss(animated: true)
    }
    
    //카메라 앨범 선택 함수
    func presentPicker(_ source : UIImagePickerController.SourceType, ImagePicker : UIImagePickerController) {
        guard UIImagePickerController.isSourceTypeAvailable(source) == true else {
            return
        }
        
        ImagePicker.delegate = self
        ImagePicker.allowsEditing = true
        ImagePicker.sourceType = source
        present(ImagePicker,animated:  true)
    }
    
    func selectimg(_ imagePickerController: UIImagePickerController) {
        let select = UIAlertController(title: "이미지 장소 선택",
                                       message: "이미지를 가져올 저장소를 선택해 주세요.",
                                       preferredStyle: .alert)
        let cameraAct = UIAlertAction(title: "카메라",
                                      style: .default) { (alert) in
                                        self.presentPicker(.camera,ImagePicker: imagePickerController)
        }
        let photoLib = UIAlertAction(title: "사진 라이브러리",
                                     style: .default) { (alert) in
                                        self.presentPicker(.photoLibrary,ImagePicker:  imagePickerController)
        }
        let saveLib = UIAlertAction(title: "저장된 앨범",
                                    style: .default) { (alert) in
                                        self.presentPicker(.savedPhotosAlbum,ImagePicker:  imagePickerController)
        }
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel)
        
        select.addAction(cameraAct)
        select.addAction(photoLib)
        select.addAction(saveLib)
        select.addAction(cancel)
        present(select,animated: true)
    }
    
}


