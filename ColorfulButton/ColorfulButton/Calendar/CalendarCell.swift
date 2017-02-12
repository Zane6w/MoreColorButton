//
//  CalendarCell.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// "今天的标识"定时器
var todayIndicatorTimer: Timer?

class CalendarCell: UICollectionViewCell {
    // MARK:- 属性
    // 按钮
    var planButton: ColorfulButton?
    // 今天日期标识指示器
    let todayIndicator = UIView()
    
    /// 按钮模型属性
    var model: StatusModel? {
        didSet {
            planButton?.becomeFirstResponder()
            
            planButton?.id = (self.model?.id)!
            planButton?.setTitle((self.model?.dayStr)!, for: .normal)
            planButton?.bgStatus = StatusType(rawValue: (self.model?.status)!)!
            planButton?.dataStr = (self.model?.dataStr)!
            
            if model?.dataStr != "" {
                planButton?.indicator.isHidden = false
            } else {
                planButton?.indicator.isHidden = true
            }
            
            opinionIndicator(button: planButton!, text: (planButton?.dataStr)!)
            
            planButton?.resignFirstResponder()
            
            DispatchQueue.main.async {
                let nowDateStr = DateTool.shared.getCompactDate()
                
                if (self.planButton?.id)! == nowDateStr {
                    self.todayIndicator.isHidden = false
                } else {
                    self.todayIndicator.isHidden = true
                }
            }
            
            if todayIndicatorTimer == nil {
                todayIndicatorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTodayIndicator), userInfo: nil, repeats: true)
            }
        }
    }
    
    // MARK:- 系统函数
    override init(frame: CGRect) {
        super.init(frame: frame)

        planButton = ColorfulButton(frame: self.bounds)
        self.contentView.addSubview(planButton!)
        
        let todayHeight: CGFloat = 2
        let todayY: CGFloat = self.bounds.height - todayHeight
        todayIndicator.frame = CGRect(x: 0, y: todayY, width: self.bounds.width, height: todayHeight)
        todayIndicator.backgroundColor = appColor
        todayIndicator.layer.cornerRadius = todayIndicator.bounds.height * 0.5
        todayIndicator.isHidden = true
        self.contentView.addSubview(todayIndicator)
        
        setupNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 随时更新"今天的标识"
    @objc fileprivate func updateTodayIndicator() {
        print("today")
        let nowDateStr = DateTool.shared.getCompactDate()
        
        if (self.planButton?.id)! == nowDateStr {
            self.todayIndicator.isHidden = false
        } else {
            self.todayIndicator.isHidden = true
        }
    }
    
    /// 按钮备注标识与菜单名称
    fileprivate func opinionIndicator(button: ColorfulButton, text: String) {
        if text != "" {
            button.indicator.isHidden = false
            
            // 判断系统当前语言
            if isChineseLanguage {
                button.remarksTitle = "编辑备注"
            } else {
                button.remarksTitle = "Edit Note"
            }
            
            button.reloadMenu()
        } else {
            
            // 判断系统当前语言
            if isChineseLanguage {
                button.remarksTitle = "添加备注"
            } else {
                button.remarksTitle = "Add Note"
            }
            
            button.indicator.isHidden = true
            button.reloadMenu()
        }
    }
    
}

// MARK:- 通知相关
extension CalendarCell {
    
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: appDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: appWillResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: appDidEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: appWillTerminateNotification, object: nil)
    }
    
}

// MARK:- 通知事件处理
extension CalendarCell {
    /// 开启定时器
    @objc fileprivate func startTimer() {
        todayIndicatorTimer?.fireDate = Date.distantPast
    }
    
    /// 暂停定时器
    @objc fileprivate func pauseTimer() {
        todayIndicatorTimer?.fireDate = Date.distantFuture
    }
    
    /// 消除定时器
    @objc fileprivate func invalidateTimer() {
        todayIndicatorTimer?.invalidate()
    }
    
}
