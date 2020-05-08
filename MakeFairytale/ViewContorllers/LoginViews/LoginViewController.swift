//
//  LoginViewController.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 02/10/2019.
//  Copyright © 2019 ByungHoon Ann. All rights reserved.
//
import Firebase
import UIKit

fileprivate let ref = Database.database().reference()
fileprivate let authRef = Auth.auth()
class LoginViewController: UIViewController{
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    
    let indicator = UIActivityIndicatorView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in })

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 15
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 15
        
    }
    
    //MARK: 로그인 기록이 있을 경우 자동 로그인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else { return }
        if Auth.auth().currentUser != nil {
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                Firestore.firestore()
                    .collection("UsingAgreeUser")
                    .document(currentUID)
                    .getDocument { snapshot, error in
                        guard let snapshot = snapshot?.data() else { return }
                        let agreeCheck = snapshot["agree"] as? Bool ?? false
                        let uid = snapshot["uid"] as? String ?? ""
                        if agreeCheck == true, uid == currentUID {
                            CurrentUID.shread.currentUID = currentUID
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            self.agreeUsingAppMessage(currentUID: currentUID) {
                               CurrentUID.shread.currentUID = currentUID
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                }
            })
        }
    }
    
    //MARK:화면 터치시 키보드 비활성화
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //MARK:로그인 버튼 함수
    @IBAction func loginBtn(_ sender : UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        Auth
            .auth()
            .signIn(withEmail: email,
                    password: password) { [weak self] authResult, error in
                        guard let self = self else { return }
                        if let error = error {
                            print("error = \(error.localizedDescription)")
                            let alert = UIAlertController(title: "정보 불일치",
                                                          message: "이메일 혹은 비밀번호가 일치하지 않거나 존재하지 않습니다", preferredStyle: .alert)
                            let okaction = UIAlertAction(title: "확인",
                                                         style: .default)
                            alert.addAction(okaction)
                            self.present(alert,animated: true)
                        }
                        
                        if let user =  authResult?.user {
                            let uid = user.uid
                            self.activityIndicatorView.startAnimating()
                            self.agreeUsingAppMessage(currentUID: uid) {
//                                guard let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else { return }
//                                self.navigationController?.pushViewController(startView, animated: true)
                                CurrentUID.shread.currentUID = uid
                                self.activityIndicatorView.stopAnimating()
                            }
                            
                            
                        }
        }
    }
        
    
    //MARK:회원가입 화면 이동 BUtton
    @IBAction func newSignBtn (_ sender : UIButton) {
        guard let vc = UIStoryboard.newSignInVC() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:비밀번호, 이메일 찾기 버튼
    @IBAction func findIdPw(_ sender: UIButton) {
        let alert = UIAlertController(title: "이메일, 비밀번호 찾기",
                                      message: "찾고자 하시는 항목을 선택해 주세요",
                                      preferredStyle: .alert)
        
        let pwAction = UIAlertAction(title: "이메일(Email)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let msg = "가입하실 때 사용하신 이메일을 입력해주세요"
            let pwAlert = UIAlertController(title: "비밀번호 찾기",
                                            message: msg,
                                            preferredStyle: .alert)
            pwAlert.addTextField()
            let cancel = UIAlertAction(title: "취소",
                                       style: .cancel)
            
            let okAction = UIAlertAction(title: "인증",
                                         style: .default) { _ in
                                            
                                            let firestoreRef = Firestore.firestore()
                                            firestoreRef
                                                .collectionGroup("user")
                                                .getDocuments { (users, error) in
                                                    if let error = error {
                                                        print("\(error.localizedDescription)")
                                                    } else {
                                                        if users != nil {
                                                            guard let users = users else { return }
                                                            for document in users.documents {
                                                                guard let email = document["email"] as? String else { return}
                                                                if email == pwAlert.textFields?[0].text {
                                                                    guard let text = pwAlert.textFields?[0].text else { return }
                                                                    authRef
                                                                        .sendPasswordReset(withEmail: text) { error in
                                                                            if let error = error {
                                                                                print("\(error.localizedDescription)")}
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                            }
            }
            pwAlert.addAction(cancel)
            pwAlert.addAction(okAction)
            self.present(pwAlert,animated: true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(pwAction)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
}

extension LoginViewController : UITextFieldDelegate {
    
    //MARK:리턴키를 누르면 키보드화면 비활성화
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func alertUsingMessage(_ currentUID: String) {
         guard let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else { return }
        let today = DateCalculation.shread.dateFomatter.string(from: Today.shread.today)
        let message = "어플리케이션 이용 중 광고 유도/선동/비속어/욕설/음란물/URL형식의 내용을 포함한 글이나 사진 대화문은 게재할 수 없으며 이를 무시하고 게재될 경우나 신고조치를 당하여 위의 제재사항에 포함된 경우 24시간 이내에 무통보 삭제 및 계정이용이 중지됩니다. 위의 제재사항을 이해하였으며 앱을 이용하시려면 동의를 눌러주세요."
        let alert = UIAlertController(title: "주의사항", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "동의", style: .default) { _ in
            Firestore.firestore()
                .collection("UsingAgreeUser")
                .document(currentUID)
                .setData( ["uid":currentUID,
                           "date":today,
                           "agree":true]) { error in
                            self.navigationController?.pushViewController(startView, animated: true)
            }
        }
        
        let cancel = UIAlertAction(title: "비동의", style: .cancel) { _ in
            Firestore.firestore().collection("Agree").document(currentUID).setData( ["uid":currentUID,
                                                                                     "date":today,
                                                                                     "agree":false])
            let msg = "동의 하지 않으면 앱을 이용하실 수 없습니다. 동의하시려면 앱을 다시 실행해주세요."
            let alert = UIAlertController(title: "안내", message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel)
            
            alert.addAction(ok)
            self.present(alert,animated: true)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }

    
    func agreeUsingAppMessage(currentUID: String, completion: @escaping () -> Void)  {
        guard let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else { return }
        Firestore.firestore()
            .collection("UsingAgreeUser")
            .document(currentUID).getDocument { snapshot, error in
                print(44444)
                guard let snapshot = snapshot?.data() else {
                    self.alertUsingMessage(currentUID)
                    completion()
                    return
                }
                let agreeCheck = snapshot["agree"] as? Bool ?? false
                let currentUID = snapshot["uid"] as? String ?? ""
                if agreeCheck == agreeCheck, currentUID == currentUID {
                    self.navigationController?.pushViewController(startView, animated: true)
                    completion()
                } else {
                    self.alertUsingMessage(currentUID)
                    completion()
                }
                
        }
    }
    



}

