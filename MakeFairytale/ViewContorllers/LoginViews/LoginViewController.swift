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
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
    }
    
    
    //MARK: 로그인 기록이 있을 경우 자동 로그인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as! UITabBarController
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                guard let currentUID = Auth.auth().currentUser?.uid else { return }
                self.appDelegate.currentUID = currentUID
                self.navigationController?.pushViewController(startView, animated: true)
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
                            guard let startView = self.storyboard?.instantiateViewController(withIdentifier: "tab") as? UITabBarController else { return }
                            self.navigationController?.pushViewController(startView, animated: true)
                            self.appDelegate.currentUID = uid
                            self.activityIndicatorView.stopAnimating()
                        }
        }
    }
        
    
    //MARK:회원가입 화면 이동 BUtton
    @IBAction func newSignBtn (_ sender : UIButton) {
        guard let loginView = storyboard?.instantiateViewController(withIdentifier: "NewSignInViewController") as? NewSignInViewController else { return }
        navigationController?.pushViewController(loginView, animated: true)
    }
    
    //MARK:비밀번호, 이메일 찾기 버튼
    @IBAction func findIdPw(_ sender: UIButton) {
        let alert = UIAlertController(title: "이메일, 비밀번호 찾기", message: "찾고자 하시는 항목을 선택해 주세요", preferredStyle: .alert)
        
        let pwAction = UIAlertAction(title: "이메일(Email)", style: .default) { (_) in
            let msg = "가입하실 때 사용하신 이메일을 입력해주세요"
            let pwAlert = UIAlertController(title: "비밀번호 찾기",
                                            message: msg,
                                            preferredStyle: .alert)
            pwAlert.addTextField()
            let cancel = UIAlertAction(title: "취소",
                                       style: .cancel)
            
            let okAction = UIAlertAction(title: "인증",
                                         style: .default) { (_) in
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
                                                                    Auth
                                                                        .auth()
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
}

