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
    
    // MARK:- 获取紧凑型当前年月日
    /// 获取紧凑型当前年月日
    func getCompactDate(dateFormat: String = "yyyyMMdd") -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: now)
    }
    
    // MARK:- 获取一个月有几天
    /// 获取一个月有几天
    /// - parameter year: 需要判断的年份（默认是今年）
    func getDayOfMonth(year: String? = nil) -> [Int] {
        
        let cmps = Calendar.current.dateComponents([.year], from: Date())
        
        if year == nil {
            return opinionDayOfMonth(year: "\(cmps.year!)")
        } else {
            return opinionDayOfMonth(year: year!)
        }
    }
    
    // 判断某年中每个月有几天
    fileprivate func opinionDayOfMonth(year: String) -> [Int] {
        var days = [Int]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        var date = Date()
        for i in 1...12 {
            if i < 10 {
                date = formatter.date(from: "\(year)-0\(i)-01 10:10:10 +0000")!
            } else {
                date = formatter.date(from: "\(year)-\(i)-01 10:10:10 +0000")!
            }
            let daysNumber = Calendar.current.range(of: .day, in: .month, for: date)?.count
            days.append(daysNumber!)
        }
        
        return days
    }
    
    // MARK:- 判断每月的第一天是星期几
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
    
    // MARK:- ID 完整年月日处理
    /// ID 完整年月日处理
    func getFullDateStrOfID(id: String) -> String {
        let year = getCompactDate(dateFormat: "yyyy")
        
        let dateTuples = filterMonthAndDay(dateStr: id, yearStr: year)
        let month = dateTuples.month
        let day = dateTuples.day

        if month.characters.count == 1 {
            if day.characters.count == 1 {
                return "\(year)0\(month.characters.last!)0\(day.characters.last!)"
            } else {
                return "\(year)0\(month.characters.last!)\(day)"
            }
        } else {
            if day.characters.count == 1 {
                return "\(year)\(month)0\(day.characters.last!)"
            } else {
                return "\(year)\(month)\(day)"
            }
        }
    }
    
    // MARK:- 筛选月份和时期
    /// 筛选月份和时期
    /// - parameter dateStr: 日期字符串
    /// - parameter year: 需要筛选的年份字符串
    func filterMonthAndDay(dateStr: String, yearStr: String) -> (month: String, day: String) {
        let strRange = Range(uncheckedBounds: (lower: dateStr.startIndex, upper: dateStr.endIndex))
        let dateRange = dateStr.range(of: yearStr, options: .backwards, range: strRange, locale: nil)
        let startIndex = dateRange!.upperBound
        
        let monthAndDayRange = Range(uncheckedBounds: (lower: startIndex, upper: dateStr.endIndex))
        
        let needStr = dateStr.substring(with: monthAndDayRange)
        let needStrCount = needStr.characters.count
        
        var offsetBy = 1
        if needStrCount == 4 {
            offsetBy = 2
        } else {
            offsetBy = 1
        }
        
        // 剩余的字符中的开头字符索引
        let dayFirstIndex = needStr.index(needStr.startIndex, offsetBy: offsetBy)
        
        // 第一个是月份
        let monthStr = needStr.substring(to: dayFirstIndex)
        
        // 剩下的是日期
        let dayStr = needStr.substring(from: dayFirstIndex)

        return (monthStr, dayStr)
    }
    
}
