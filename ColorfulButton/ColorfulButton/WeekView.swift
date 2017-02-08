//
//  WeekView.swift
//  Calendar
//
//  Created by zhi zhou on 2017/1/24.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// 顶部日期更新定时器
var weekViewTimer: Timer?

class WeekView: UIView {
    // MARK:- 属性
    /// 星期数组
    fileprivate var weekTitles = [String]()
    
    /// 当前日期文字
    var weekday = ""
    
    var weeksButtons = [UIButton]()
    
    /// 首个工作日（默认星期日: 0）
    /// - 周日、 周一 ~ 周六标识: 0、1 ~ 6
    var firstWorkday = 0 {
        didSet {
            // 判断系统当前语言
            let languages = Locale.preferredLanguages
            let currentLanguage = languages[0]
            // 判断是否是中文, 根据语言设置字体样式
            /*
             en-US: 英语美国
             en-GB: 英语英国
             zh-Hans-US: 中文-简体-地区美国
             zh-Hant-US: 中文-繁体-地区美国
             ja-CN: 日语-地区中国
             */
            
            // 周一 ~ 周日 对应数字: [ 2 3 4 5 6 7 1 ]
            let weekday = Calendar.current.component(.weekday, from: Date())
            
            if currentLanguage.hasPrefix("zh") {
                let weeks = ["日", "一", "二", "三", "四", "五", "六"]
                self.weekday = weeks[weekday - 1]
                weekTitles = sortWeeks(weeks, firstWorkday: firstWorkday)
            } else {
                let weeks = ["Sun.", "Mon.", "Tues.", "Wed.", "Thur.", "Fri.", "Sat."]
                self.weekday = weeks[weekday - 1]
                weekTitles = sortWeeks(weeks, firstWorkday: firstWorkday)
            }
            
            setupInterface()
            
            for weekBtn in weeksButtons {
                if (weekBtn.titleLabel?.text)! == self.weekday {
                    weekBtn.isSelected = true
                } else {
                    weekBtn.isSelected = false
                }
            }
        }
    }
    
    // MARK:- 方法函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupInterface() {
        self.backgroundColor = .clear
        self.tintColor = .black

        setBlur()
        
        let buttonWidth: CGFloat = self.bounds.width / 7
        var buttonX: CGFloat = 0
        for i in 0..<7 {
            let weekButton = UIButton(type: .system)
            
            weekButton.isUserInteractionEnabled = false
            
            weekButton.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: self.bounds.height)
            
            buttonX += buttonWidth
            
            weekButton.isOpaque = true
            weekButton.setTitle(weekTitles[i], for: .normal)
            
            weeksButtons.append(weekButton)
            
            self.addSubview(weekButton)
        }
    }
    
    /// 蒙版
    fileprivate func setBlur() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        self.addSubview(blurEffectView)
    }
    
    /// 根据第一个工作日排序日期列表
    fileprivate func sortWeeks(_ weeks: [String], firstWorkday: Int) -> [String] {
        // 第一个工作日之前的星期
        var beforeArr = [String]()
        for i in 0..<firstWorkday {
            beforeArr.append(weeks[i])
        }
        
        // 第一个工作日之后的星期
        var afterArr = [String]()
        for i in firstWorkday...(weeks.count - 1) {
            afterArr.append(weeks[i])
        }
        
        return afterArr + beforeArr
    }
    
    fileprivate func setupTimer() {
        weekViewTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(weekTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func weekTimer() {
        let languages = Locale.preferredLanguages
        let currentLanguage = languages[0]
        
        // 周一 ~ 周日 对应数字: [ 2 3 4 5 6 7 1 ]
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        if currentLanguage.hasPrefix("zh") {
            let weeks = ["日", "一", "二", "三", "四", "五", "六"]
            self.weekday = weeks[weekday - 1]
            weekTitles = sortWeeks(weeks, firstWorkday: firstWorkday)
        } else {
            let weeks = ["Sun.", "Mon.", "Tues.", "Wed.", "Thur.", "Fri.", "Sat."]
            self.weekday = weeks[weekday - 1]
            weekTitles = sortWeeks(weeks, firstWorkday: firstWorkday)
        }
        
        for weekBtn in weeksButtons {
            if (weekBtn.titleLabel?.text)! == self.weekday {
                weekBtn.isSelected = true
            } else {
                weekBtn.isSelected = false
            }
        }
    }
    
}
