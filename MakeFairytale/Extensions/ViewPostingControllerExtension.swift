//
//  ViewPostingControllerExtension.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/05/11.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit
import Firebase

//FIXME : 추가기능 넣기
//FIXME: 서버쪽에서 작업할지 코드로 할지 유보 
extension ViewPostingController {
    func selectAlertType(by orderSelect: SelectedType) -> AlertComponents {
         let _postUID = post?.userUID ?? ""
        switch orderSelect {
        case .option:
            let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
                CommonService.shread.orderSelect = .option
            }
            
            let rePostAction = AlertActionComponent(title: "수정", style: .default) { _ in
                
            }
            
            let deleteAction = AlertActionComponent(title: "삭제", style: .default) { _ in
                
            }
            
            let blockAction = AlertActionComponent(title: "차단(Block)", style: .destructive) { _ in
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
        let okAction = AlertActionComponent(title: "차단", style: .destructive) { _ in
            //FIXME: 차단 기능
            CommonService.shread.orderSelect = .option
            print("차단")
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
        let reportMessage = "신고를 하시면 24시간 내에 신고된 컨텐츠의 내용을 확인한 후 제재가 결정됩니다."
        let okAction = AlertActionComponent(title: "신고", style: .destructive) { _ in
            //FIXME: 신고기능
            CommonService.shread.orderSelect = .option
            print("신고")
        }
        let cancel = AlertActionComponent(title: "취소", style: .cancel) { _ in
            CommonService.shread.orderSelect = .option
        }
        let alert = AlertComponents(title: "차단", message: reportMessage, actions:[okAction,cancel])
        return alert
    }
    
    
}
