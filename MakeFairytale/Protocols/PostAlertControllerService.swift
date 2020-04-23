//
//  PostAlertControllerService.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/23.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

fileprivate let postRef = Firestore.firestore().posts
fileprivate let storeRef = Storage.storage()
fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
struct AlertComponents {
    var title: String?
    var message: String?
    var actions: [UIAlertAction]
    var completion: (() -> Void)?
    
    init(title:String?,
         message: String? = nil,
         actions: [AlertActionComponent],
         completion: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.completion = completion
        self.actions = actions.map{
            UIAlertAction(title: $0.title, style: $0.style, handler: $0.hander)
        }
    }
}

struct AlertActionComponent {
    var title: String
    var style: UIAlertAction.Style
    var hander: ((UIAlertAction) -> Void)?
    
    init(title:String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction)-> Void)?) {
        self.title = title
        self.style = style
        self.hander = handler
    }
}

protocol AlertPresentable where Self: UIViewController {
    var alertStyle: UIAlertController.Style { get }
    var alertComponents: AlertComponents { get }
}

extension AlertPresentable {
    private var alertTitle: String? {
        return alertComponents.title
    }
    
    private var message: String? {
        return alertComponents.message
    }
    
    private var actions: [UIAlertAction] {
        return alertComponents.actions
    }
    
    var alertStyle: UIAlertController.Style {
        return .actionSheet
    }
    
    private var completion: (() -> Void)? {
        return alertComponents.completion
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: alertStyle)
        actions.forEach {alert.addAction($0) }
        present(alert, animated: true, completion: completion)
    }
}

extension ListViewController: AlertPresentable {
   
    var alertComponents: AlertComponents {
        let indexPath = appDelegate.indexPath ?? IndexPath(row:festaData.count - 1, section:0)
        let currentUID = appDelegate.currentUID ?? ""
        let deleteAction = AlertActionComponent(title: "삭제") { [weak self] _ in
            guard let self = self else { return }
            let postURL = self.festaData[indexPath.row]
            for i in 0 ..< postURL.userPostImage.count {
                storeRef
                    .reference(forURL: "\(postURL.userPostImage[i])")
                    .delete { (error) in
                        if let _error = error {
                            print("storage Error! = \(_error.localizedDescription)")}
                }
            }
            
            postRef
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
        
        let detailAlert = AlertActionComponent(title: "자세히 보기") { [weak self] _ in
            guard let vc = UIStoryboard.viewPostingVC() else { return }
            guard let self = self else { return }
            vc.post = self.festaData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let messageAlert = AlertActionComponent(title: "쪽지 보내기") { [weak self] _ in
            guard let self = self else { return }
            guard let vc = UIStoryboard.chattingRoomVC() else { return }
            vc.yourUID = self.festaData[indexPath.row].userUID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancelAction = AlertActionComponent(title: "취소", handler: nil)
        
        let alertComponents = AlertComponents(title: "안내", actions: [detailAlert,messageAlert,cancelAction])
        
        if self.festaData[indexPath.row].userUID == currentUID {
            let myComponentss = AlertComponents(title: "안내", actions: [detailAlert,deleteAction,cancelAction])
            return myComponentss
        } else {
            return alertComponents
        }
    }
}

