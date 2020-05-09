//
//  NewSignInViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 02/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
//회원가입 뷰
//리펙토링 + UI디자인 기능 안정성 개선 필요

import UIKit
import Firebase

class NewSignInViewController : UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var firstProfileImg : UIImageView!
    @IBOutlet weak var emailSignFelid: UITextField! //가입할 이메일 입력 필드
    @IBOutlet weak var nickNameSignField: UITextField! //가입후 사용할 이름
    @IBOutlet weak var passwordSignField: UITextField! //패스워드  필드
    @IBOutlet weak var checkPasswordSignField: UITextField! //패스워드 재확인 필드
   
    var pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapgestur = UITapGestureRecognizer(target: self, action: #selector(selectProfileImg))
        
        firstProfileImg.layer.cornerRadius = firstProfileImg.frame.height/2
        firstProfileImg.clipsToBounds = true
        firstProfileImg.addGestureRecognizer(tapgestur)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertUsingMessage()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    //빈사람 클릭시 사진선택 화면 띄우기 제스쳐 설쩡
    @objc func selectProfileImg() {
        selectimg(pickerController)
    }
    
    func selectimg(_ imagePickerController: UIImagePickerController) {
        let select = UIAlertController(title: "이미지 장소 선택",
                                       message: "이미지를 가져올 저장소를 선택해 주세요.",
                                       preferredStyle: .alert)
        let cameraAct = UIAlertAction(title: "카메라",
                                      style: .default) { (alert) in
                                        self.presentPicker(.camera,
                                                           ImagePicker: imagePickerController)
        }
        
        let photoLib = UIAlertAction(title: "사진 라이브러리",
                                     style: .default) { (alert) in
                                        self.presentPicker(.photoLibrary,ImagePicker:  imagePickerController)
        }
        
        let saveLib = UIAlertAction(title: "저장된 앨범",
                                    style: .default) { (alert) in
                                        self.presentPicker(.savedPhotosAlbum,
                                                           ImagePicker:  imagePickerController)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        select.addAction(cameraAct)
        select.addAction(photoLib)
        select.addAction(saveLib)
        select.addAction(cancel)
        present(select,animated: true)
    }
    
    @IBAction func creatUser(_ sender : UIButton) {
        if CurrentUID.shread.usingAgree == true {

        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        guard let emailFieldText = emailSignFelid.text else { return }
        guard let passwordFieldText = passwordSignField.text else { return }
        if emailFieldText.checkingEmailPassword() == false {
            Auth
                .auth()
                .createUser(withEmail: emailFieldText,
                            password: passwordFieldText) { (user,error) in
                
                if user != nil {
                    guard let user = Auth.auth().currentUser else { return } //유저 고유 UID
                    let firestoreRef = Firestore.firestore().collection("user")
                    let storageRef = Storage.storage().reference(forURL: "gs://festargram.appspot.com/").child("ProfileImage").child("\(user.uid)") //프로필사진경로
                    
                    //프로필 이미지 업로드
                    if let profileIMG = self.firstProfileImg.image, let imageData = profileIMG.jpegData(compressionQuality: 0.5) {
                        storageRef
                            .putData(imageData,
                                     metadata: nil,
                                     completion: { download,error in
                                        
                            if error != nil { return }
                        
                            storageRef
                                .downloadURL { url,error in
                                    
                                if error != nil {return}
                                    guard let profileImgURL = url?.absoluteString else { return }//위의 선언해둔 옵셔널 문자열에 url string변수 삽입
                                guard let signFieldText = self.nickNameSignField.text else { return }
                                    firestoreRef
                                        .document("\(user.uid)")
                                        .setData([
                                            "uid":user.uid,
                                            "email": emailFieldText,
                                            "nickName":signFieldText,
                                            "profileImageURL":profileImgURL,
                                            "password": passwordFieldText,
                                            "like":false,
                                            "newPost":false,
                                            "chatting":false,
                                            "reple":false,
                                            "follow":false
                                        ]) { error in
                                            CurrentUID.shread.currentUID = user.uid
                                            guard let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else {return}
                                            self.activityIndicatorView.stopAnimating()
                                            self.navigationController?.pushViewController(startView, animated: true)
                                            if let error = error   {  print("\(error.localizedDescription)")}
                                    }
                            }
                            })
                    }
                } else {
                    //이메일 양식이 틀렸을 경우
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicatorView.stopAnimating()
                    let alert = UIAlertController(title: "알림", message: "이메일 형식에 맞지 않습니다", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "확인", style: .cancel)
                    alert.addAction(cancel)
                    self.present(alert,animated: true)
                }
            }
        }
        } else {
            alertUsingMessage()
        }
    }
    
    @IBAction func creatCancel(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

//이미지피커 컨트롤러 설정
extension NewSignInViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        firstProfileImg.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
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
}

extension NewSignInViewController {
    func alertUsingMessage() {
        if CurrentUID.shread.usingAgree == false {
            let message = "어플리케이션 이용 중 광고 폭력/아동,동물 및 모든 학대/선동/비속어/욕설/음란물/URL형식의 내용을 포함한 글이나 사진, 대화문, 프로필 사진은 게재할 수 없으며 이를 무시하고 게재 될 경우나 신고 조치를 당하여 위의 제재사항에 포함된 경우 24시간 이내에 무통보 삭제 및 계정이용이 중지됩니다. 위의 제재사항을 이해하였으며 앱을 이용하시려면 동의를 눌러주세요."
            let alert = UIAlertController(title: "주의사항", message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "동의", style: .default) { _ in
                CurrentUID.shread.usingAgree = true
            }
            
            let cancel = UIAlertAction(title: "비동의", style: .cancel) { _ in
                CurrentUID.shread.usingAgree = false
                let msg = "동의 하지 않으면 회원가입이 마무리 되지 않습니다."
                let alert = UIAlertController(title: "안내", message: msg, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .cancel)
                
                alert.addAction(ok)
                self.present(alert,animated: true)
            }
            
            alert.addAction(okAction)
            alert.addAction(cancel)
            self.present(alert,animated: true)
        }
    }

}

extension String {
    //회원가입 도중 이메일형식이 틀리거나 비밀번호가 6자리 이하일때 실행될 메소드
    func checkingEmailPassword() -> Bool {
        let rightEmail = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%+-]+.\\[A-Za-z]{2,6}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", rightEmail)
        return emailPredicate.evaluate(with: self)
    }
}
