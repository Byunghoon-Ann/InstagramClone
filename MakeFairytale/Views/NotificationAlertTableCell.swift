//
//  NotificationAlertTableCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/11.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

class NotificationAlertTableCell: UITableViewCell {
    @IBOutlet weak var userThumbnail: UIImageView!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var alertContents: UILabel!
    
    let dateFomatter : DateFormatter = {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFomatter.locale = Locale(identifier: "kr_KR")
        return dateFomatter
    }()
    
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var alertsData: NotificationData? {
        didSet {
            guard let alertData = alertsData else { return }
            alertDate.text = postingDateCalculation(alertData.alertDate)
            if alertData.userThumbnail == "" {
                userThumbnail.image = UIImage(named: "userSelected@40x40")
            }
            userThumbnail.sd_setImage(with: URL(string: alertData.userThumbnail))
            alertContents.text = alertData.alertContent
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userThumbnail.layer.cornerRadius = userThumbnail.frame.height/2
    }
    
    func postingDateCalculation(_ stringDate: String) -> String {
        let dateString = dateFomatter.string(from: today)
        let nowToday = dateFomatter.date(from: dateString) ?? today
        let postdates = dateFomatter.date(from: stringDate) ?? today
        let calendarC = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: postdates,to: nowToday)
        
        if case let (y?, m?, d?, h?, mi?, s?) = (calendarC.year, calendarC.month, calendarC.day, calendarC.hour,calendarC.minute,calendarC.second) {
            if y == 0, m == 0, d == 0, h == 0, mi == 0  {
                return "\(s)초 전"
            } else if y == 0, m == 0, d == 0, h == 0, mi >= 1 {
                return "\(mi)분 전"
            } else if y == 0, m == 0, d == 0, h >= 1 {
                return "\(h)시간 전"
            }else if  y == 0, m == 0, d >= 1{
                return "\(d)일 전"
            }else if y == 0, m >= 1, d >= 30 {
                return "\(m)개월 전"
            }else if y >= 1, m >= 12 {
                return "\(y)년 전"
            }
        }
        return "\(today)"
    }
}
