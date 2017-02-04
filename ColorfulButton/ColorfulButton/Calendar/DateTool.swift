//
//  DateTool.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class DateTool: NSObject {
    static let shared = DateTool()
    
    /// 获取一个月有几天
    func getDayOfMonth() -> [Int] {
        var days = [Int]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let cmps = Calendar.current.dateComponents([.year], from: Date())
        
        var date = Date()
        for i in 1...12 {
            if i < 10 {
                date = formatter.date(from: "\(cmps.year!)-0\(i)-01 10:10:10 +0000")!
            } else {
                date = formatter.date(from: "\(cmps.year!)-\(i)-01 10:10:10 +0000")!
            }
            let daysNumber = Calendar.current.range(of: .day, in: .month, for: date)?.count
            days.append(daysNumber!)
        }
        
        return days
    }
    
    /// 判断每月的第一天是星期几
    func getFirstMonthDayOfWeek() -> [Int] {
        var weekdays = [Int]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let year = Calendar.current.component(.year, from: Date())
        
        var date = Date()
        for i in 1...12 {
            if i < 10 {
                date = formatter.date(from: "\(year)-0\(i)-01 10:10:10 +0000")!
            } else {
                date = formatter.date(from: "\(year)-\(i)-01 10:10:10 +0000")!
            }
            
            let weekday = Calendar.current.component(.weekday, from: date) - 1
            weekdays.append(weekday)
        }
        
        return weekdays
    }
    
}
