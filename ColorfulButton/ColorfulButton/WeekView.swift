//
//  WeekView.swift
//  Calendar
//
//  Created by zhi zhou on 2017/1/24.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// 星期排列方式
enum SortedType {
    /// 按照给定的第一工作日排序
    case Normal
    
    /// 今天永远在右侧排序
    case Right
}

class WeekView: UIView {
    // MARK:- 属性
    /// 星期数组
    fileprivate var weekTitles = [String]()
    /// 蒙版
    fileprivate var blurEffectView: UIVisualEffectView?
    
    /// 顶部日期更新定时器
    var weekViewTimer: Timer?
    
    /// 今天的星期（被选中的星期按钮）
    var selectedWeek: UIButton? {
        didSet {
            NotificationCenter.default.post(Notification(name: timeChangeNotification))
        }
    }
    
    /// 当前日期文字
    fileprivate var weekday = ""
    /// 当前日期数字
    fileprivate var weekdayNumber = 1
    
    /// 当前月份
    fileprivate var month = 1
    
    /// 所有按钮数组
    fileprivate var weeksButtons = [UIButton]()
    
    /// 排序方式（默认安给定的第一个工作日排序）
    var sorted: SortedType = .Normal
    
    /// 中文日期标题数组
    fileprivate let chineseWeekTitles = ["日", "一", "二", "三", "四", "五", "六"]
    /// 其他语言日期标题数组
    fileprivate let otherLanguageWeekTitles = ["Sun.", "Mon.", "Tues.", "Wed.", "Thur.", "Fri.", "Sat."]
    
    /// 首个工作日（默认星期日: 0）
    /// - 周日、 周一 ~ 周六标识: 0、1 ~ 6
    var firstWorkday = 0 {
        didSet {
            // 周一 ~ 周日 对应数字: [ 2 3 4 5 6 7 1 ]
            let weekday = Calendar.current.component(.weekday, from: Date())
            self.weekdayNumber = weekday
            
            if isChineseLanguage {
                self.weekday = chineseWeekTitles[weekday - 1]
                if sorted == .Normal {
                    weekTitles = sort(weeks: chineseWeekTitles, firstWorkday: firstWorkday)
                } else {
                    weekTitles = sortTodayIsRight(weeks: chineseWeekTitles)
                }
            } else {
                self.weekday = otherLanguageWeekTitles[weekday - 1]
                if sorted == .Normal {
                    weekTitles = sort(weeks: otherLanguageWeekTitles, firstWorkday: firstWorkday)
                } else {
                    weekTitles = sortTodayIsRight(weeks: otherLanguageWeekTitles)
                }
            }
            
            setupInterface()
            
            opinionSelectedButton()
        }
    }
    
    // MARK:- 方法函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.month = Calendar.current.component(.month, from: Date())
        
        setupTimer()
        setupNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupInterface() {
        self.backgroundColor = .clear
        self.tintColor = .black

        setBlur()
        
        for weekButton in weeksButtons {
            weekButton.removeFromSuperview()
        }
        
        weeksButtons.removeAll()
        
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
        if blurEffectView == nil {
            let blurEffect = UIBlurEffect(style: .extraLight)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = self.bounds
            self.addSubview(blurEffectView!)
        }
    }
    
    /// 根据第一个工作日排序日期列表
    fileprivate func sort(weeks: [String], firstWorkday: Int) -> [String] {
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
    
    /// 今天永远在最右侧排序
    fileprivate func sortTodayIsRight(weeks: [String]) -> [String] {
        // 周日 1， 周一~周六： 2 3 4 5 6 7
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        if weekday == 7 {
            return weeks
        } else {
            // 今天
            let todayArr = [weeks[weekday - 1]]
            
            var beforeArr = [String]()
            for i in 0..<weekday - 1 {
                beforeArr.append(weeks[i])
            }
            
            var afterArr = [String]()
            for i in weekday...weeks.count - 1 {
                afterArr.append(weeks[i])
            }
            
            return afterArr + beforeArr + todayArr
        }
    }
    
    fileprivate func setupTimer() {
        weekViewTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(weekTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func weekTimer() {
        // 周一 ~ 周日 对应数字: [ 2 3 4 5 6 7 1 ]
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        if isChineseLanguage {
            self.weekday = chineseWeekTitles[weekday - 1]
            if sorted == .Normal {
                weekTitles = sort(weeks: chineseWeekTitles, firstWorkday: firstWorkday)
            } else {
                weekTitles = sortTodayIsRight(weeks: chineseWeekTitles)
                
                if self.weekdayNumber != weekday {
                    setupInterface()
                    self.weekdayNumber = weekday
                }
            }
        } else {
            self.weekday = otherLanguageWeekTitles[weekday - 1]
            if sorted == .Normal {
                weekTitles = sort(weeks: otherLanguageWeekTitles, firstWorkday: firstWorkday)
            } else {
                weekTitles = sortTodayIsRight(weeks: otherLanguageWeekTitles)
                
                if self.weekdayNumber != weekday {
                    setupInterface()
                    self.weekdayNumber = weekday
                }
            }
        }
        
        opinionSelectedButton()
    }
    
    /// 判断选中哪个按钮
    fileprivate func opinionSelectedButton() {
        for weekBtn in weeksButtons {
            if (weekBtn.titleLabel?.text)! == self.weekday {
                weekBtn.isSelected = true
                let month = Calendar.current.component(.month, from: Date())
                if selectedWeek != weekBtn {
                    selectedWeek = weekBtn
                }
                
                if self.month != month {
                    selectedWeek = weekBtn
                }
                
            } else {
                weekBtn.isSelected = false
            }
        }
    }
    
}

// MARK:- 通知相关
extension WeekView {
    
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: appDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: appWillResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: appDidEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: appWillTerminateNotification, object: nil)
    }
    
}

// MARK:- 通知事件处理
extension WeekView {
    /// 开启定时器
    @objc fileprivate func startTimer() {
        weekViewTimer?.fireDate = Date.distantPast
    }
    
    /// 暂停定时器
    @objc fileprivate func pauseTimer() {
        weekViewTimer?.fireDate = Date.distantFuture
    }
    
    /// 消除定时器
    @objc fileprivate func invalidateTimer() {
        weekViewTimer?.invalidate()
    }
    
}
