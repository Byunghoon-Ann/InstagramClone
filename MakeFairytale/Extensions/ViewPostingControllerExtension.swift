//
//  ViewPostingControllerExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/05/11.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase
fileprivate let reportRef = Firestore.firestore().collection("ReportList")
//FIXME : 추가기능 넣기
fileprivate let reportCompleteMsg = "신고조치가 완료되었습니다 24시간 이내 확인 후 위반 사항에 충족되면 제재조치가 이루어집니다."
extension ViewPostingController {
        
    func selectAlertType(by orderSelect: SelectedType) -> AlertComponents {
         let _postUID = post?.userUID ?? ""
        switch orderSelect {
        case .option:
            let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
                CommonService.shread.orderSelect = .option
            }
            
            let rePostAction = AlertActionComponent(title: "수정", style: .default) { [weak self]  _ in
                guard let self = self else { return }
                CommonService.shread.orderSelect = .logout
                self.presentAlert(.alert)
            }
            
            let deleteAction = AlertActionComponent(title: "삭제", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presentAlert(.alert)
            }
            
            let blockAction = AlertActionComponent(title: "차단(Block)", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                CommonService.shread.orderSelect = .block
                self.presentAlert(.alert)
            }
            
            let report = AlertActionComponent(title: "신고(Report)", style: .default) { _ in
                CommonService.shread.orderSelect = .report
                self.presentAlert(.alert)
            }
            
            if _postUID == CurrentUID.shread.currentUID {
                let alert = AlertComponents(title: "관리", message: "관리할 항목을 선택해주세요.", actions: [cancel,deleteAction,rePostAction])
                return alert
            } else {
                let alert = AlertComponents(title: "설정", message: "관련 항목을 선택해주세요.", actions: [cancel,blockAction,report])
                return alert
            }
            
        case .block:
            return blockAction()
        case .report:
            return reportAction()
        case .logout:
            return outAction()
        }
    }
    
    func blockAction() -> AlertComponents {
        let blockMessage = "차단을 하시면 해당 유저에 관련된 모든 것을 두번 다시 볼 수 없게 됩니다. 차단하시겠습니까?"
        let okAction = AlertActionComponent(title: "차단", style: .destructive) { [weak self] _ in
            //FIXME: 차단 기
            guard let self = self else { return }
            guard let currentUID = CurrentUID.shread.currentUID else { return }
            let userUID = self.post?.userUID ?? ""
            Firestore.firestore().collection("BlockList")
                .document(currentUID).setData(["uid":userUID]) { error in
                    Firestore.firestore().followerRef(currentUID).document(userUID).delete() {  error in
                        Firestore.firestore().followingRef(currentUID).document(userUID).delete() { error in
                            CommonService.shread.orderSelect = .option
                            State.shread.autoRefreshingCheck = true
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
            }
        }
        
        let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
            CommonService.shread.orderSelect = .option
        }
        let alert = AlertComponents(title: "차단", message: blockMessage, actions:[okAction,cancel])
        return alert
    }
    
    func outAction() -> AlertComponents {
        
        let outMessage = "대화방을 나가면 대화 기록이 없어집니다. 나가시겠습니까?"
        let okAction = AlertActionComponent(title: "나가기", style: .destructive) { _ in
            //FIXME: 나가기 기능
            CommonService.shread.orderSelect = .option
            print("나가기")
        }
        let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
            CommonService.shread.orderSelect = .option
        }
        let alert = AlertComponents(title: "차단", message: outMessage, actions:[okAction,cancel])
        return alert
    }
    
    func reportAction() -> AlertComponents {
        let errorAction = AlertActionComponent(title: "확인", style: .cancel, handler: nil)
        guard let currentUID = CurrentUID.shread.currentUID,
            let _post = post else {
                return AlertComponents(title: "올바르지 못한 접근", actions: [errorAction])
        }
        
        let reportMessage = "신고를 하시면 24시간 내에 신고된 컨텐츠의 내용을 확인한 후 제재가 결정됩니다."
        let okAction = AlertActionComponent(title: "신고", style: .destructive) { [weak self] _ in
            //FIXME: 신고기능
            guard let self = self else { return }
            let alert = UIAlertController(title: "신고사유", message: "신고 사유를 정해주세요", preferredStyle: .alert)
            let unsafe = UIAlertAction(title: "부적절한 콘텐츠", style: .default) { _ in
                reportRef
                    .document(_post.userUID)
                    .collection(currentUID)
                    .addDocument(data: ["reportType":"UnsafeContent",
                                        "urlKey":_post.urlkey,
                                        "reporter":currentUID]) { error in
                    let alert = UIAlertController(title: "완료", message: reportCompleteMsg, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(ok)
                    self.present(alert,animated: true)
                }
            }
            let spam = UIAlertAction(title: "스팸", style: .default) { _ in
                reportRef
                    .document(_post.userUID)
                    .collection(currentUID)
                    .addDocument(data: ["reportType":"SpamContent",
                                        "urlKey":_post.urlkey,
                                        "reporter":currentUID]) { error in
                    let alert = UIAlertController(title: "완료", message: reportCompleteMsg, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(ok)
                    self.present(alert,animated: true)
                }
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(unsafe)
            alert.addAction(spam)
            alert.addAction(cancel)
            self.present(alert,animated: true)
            
            CommonService.shread.orderSelect = .option
        }
        let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
            CommonService.shread.orderSelect = .option
        }
        let alert = AlertComponents(title: "신고", message: reportMessage, actions:[okAction,cancel])
        return alert
    }
    
    
}
