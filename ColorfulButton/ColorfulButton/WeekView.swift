//
//  WeekView.swift
//  Calendar
//
//  Created by zhi zhou on 2017/1/24.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class WeekView: UIView {
    // MARK:- 属性
    /// 星期数组
    fileprivate var weekTitles = [String]()
    
    // MARK:- 方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        print(currentLanguage)
        if currentLanguage.hasPrefix("zh") {
            weekTitles = ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            weekTitles = ["Mon.", "Tues.", "Wed.", "Thur.", "Fri.", "Sat.", "Sun."]
        }

        setupInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupInterface() {
        self.backgroundColor = .clear
        self.tintColor = .black
        self.bounds = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 30))
        
        setBlur()
        
        let chineseWeekday = Calendar.current.component(.weekday, from: Date()) - 1
        
        let buttonWidth: CGFloat = self.bounds.width / 7
        var buttonX: CGFloat = 0
        for i in 0..<7 {
            let weekButton = UIButton(type: .system)
            weekButton.isUserInteractionEnabled = false
            weekButton.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: self.bounds.height)
            buttonX += buttonWidth
            
            weekButton.setTitle(weekTitles[i], for: .normal)

            if (i + 1) == chineseWeekday {
                weekButton.isSelected = true
            }
            
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
    
}
