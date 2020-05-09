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
        self.actions = actions.map {
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

protocol AlertPresentable   {
    var optionAlertComponents: AlertComponents { get }
    func selectAlertType(by orderSelect: SelectedType) -> AlertComponents
}

extension AlertPresentable where Self: UIViewController {
    private var alertTitle: String? {
        return optionAlertComponents.title
    }
    
    private var message: String? {
        return optionAlertComponents.message
    }
    
    private var actions: [UIAlertAction] {
        return optionAlertComponents.actions
    }
    
    var alertStyle: UIAlertController.Style {
        return .actionSheet
    }
    
    private var completion: (() -> Void)? {
        return optionAlertComponents.completion
    }
    
    func presentAlert(_ alertStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: alertStyle)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: completion)
    }

}

extension ListViewController: AlertPresentable {
    func optionAction(_ selectType: SelectedType ,
                      _ tableView: UITableView) -> AlertComponents {
        let indexPath = AnimationControl.shread.indexPath ?? IndexPath(row: festaData.count - 1, section:0)
        let currentUID = CurrentUID.shread.currentUID ?? ""
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
            tableView.beginUpdates()
            self.festaData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
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
            CurrentUID.shread.yourUID = self.festaData[indexPath.row].userUID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let reportAction = AlertActionComponent(title: "신고", style: .destructive) { _ in
            CommonService.shread.orderSelect = .report
            self.presentAlert(.alert)
        }
       
        let blockAction = AlertActionComponent(title: "차단", style: .destructive) { action in
            CommonService.shread.orderSelect = .block
            self.presentAlert(.alert)
        }
    
        let cancelAction = AlertActionComponent(title: "취소", handler: nil)

        let alertComponents = AlertComponents(title: "안내", actions: [reportAction,blockAction,detailAlert,messageAlert,cancelAction])
        
        if festaData[indexPath.row].userUID == currentUID {
            let myComponentss = AlertComponents(title: "안내", actions: [detailAlert,deleteAction,cancelAction])
            return myComponentss
        } else {
            return alertComponents
        }
    }
    
    func logoutAction () -> AlertComponents {
        let cancel = AlertActionComponent(title: "취소", style: .cancel,handler: nil)
        let logoutAction = AlertActionComponent(title: "로그아웃") { [weak self] _ in
            guard let self = self else { return }
            do {
                try Auth.auth().signOut()
                guard let vc = UIStoryboard.loginVC() else { return }
                self.navigationController?.pushViewController(vc, animated: true)
                CommonService.shread.orderSelect = .option
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
        return AlertComponents(title: "로그아웃", actions: [logoutAction,cancel])
    }
    
    func blockAlert() -> AlertComponents {
        let message = "차단을 하시면 해당 유저에 관련된 모든 것을 두번 다시 볼 수 없게 됩니다. 차단하시겠습니까?"
        
        let okAction = AlertActionComponent(title: "차단(Block)", style: .destructive) { _ in
            guard let currentUID = CurrentUID.shread.currentUID else { return }
            guard let indexPath = AnimationControl.shread.indexPath else { return }
            let userUID = self.festaData[indexPath.row].userUID
            Firestore.firestore().collection("BlockList")
                .document(currentUID).setData(["uid":userUID]) { error in
                    Firestore.firestore().followerRef(currentUID).document(userUID).delete() {  error in
                        Firestore.firestore().followingRef(currentUID).document(userUID).delete() { error in
                            CommonService.shread.orderSelect = .option

                            self.loadFesta()
                        }
                    }

            }
        }
        
        let cancel = AlertActionComponent(title: "취소", style: .cancel, handler: nil)
        let alert = AlertComponents(title: "차단", message: message, actions: [cancel,okAction])
       
        return alert
    }
    
    func reportAction() -> AlertComponents {
        let okAction = AlertActionComponent(title: "신고", style: .destructive) { _ in
//            CommonService.shread.orderSelect = .option

//            guard let currentUID = CurrentUID.shread.currentUID else { return }
//            guard let indexPath = AnimationControl.shread.indexPath else { return }
//            let data = self.festaData[indexPath.row]
//            Firestore.firestore().collection("ReportList").document(data.userUID).collection(currentUID).addDocument(data: ["reportType":"","urlKey":data.urlkey,"reporter":currentUID])
        }
        
        let cancel = AlertActionComponent(title: "취소", style: .cancel,handler: nil)
        
        let alert = AlertComponents(title: "신고", message: "신고하시겠습니까?", actions: [cancel,okAction])
        
        return alert
    }
    
    func selectAlertType(by orderSelect: SelectedType) -> AlertComponents {
        switch orderSelect {
        case .option:
            return optionAction(.option, postTableView)
        case .logout:
            return logoutAction()
        case .block:
            return blockAlert()
        case .report:
            return reportAction()
        }
    }

    var optionAlertComponents: AlertComponents {
        return selectAlertType(by: CommonService.shread.orderSelect)
    }
}

