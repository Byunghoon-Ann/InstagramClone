//
//  ExtensionTableViewCell.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/02/14.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func actionControlOption(_ festaData: Posts,
                             _ pageControl: UIPageControl) {
        pageControl.numberOfPages = festaData.userPostImage.count
        if festaData.userPostImage.count == 1 {
            pageControl.isHidden = true
        }else {
            pageControl.isHidden = false
        }
    }
    
    func postingDateCalculation(_ stringDate: String,
                                _ dateFomatter: DateFormatter,
                                _ today: Date,
                                _ calendar: Calendar) -> String {
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
            }else if y == 0, m >= 1 {
                return "\(m)개월 전"
            }else if y >= 1, m >= 12 {
                return "\(y)년 전"
            }
        }
        return "\(today)"
    }
    
}
