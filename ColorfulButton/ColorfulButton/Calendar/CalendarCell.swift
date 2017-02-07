//
//  CalendarCell.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    // MARK:- 属性
    // 按钮
    var planButton: ColorfulButton?
    
    /// 语言判断
    var isHanLanguage: Bool {
        // 判断系统当前语言
        let languages = Locale.preferredLanguages
        let currentLanguage = languages[0]
        // 判断是否是中文, 根据语言设置字体样式
        if currentLanguage.hasPrefix("zh") {
            return true
        } else {
            return false
        }
    }
    
    /// 按钮模型属性
    var model: StatusModel? {
        didSet {
            planButton?.becomeFirstResponder()
            
            planButton?.id = (self.model?.id)!
            planButton?.setTitle((self.model?.dateStr)!, for: .normal)
            planButton?.bgStatus = StatusType(rawValue: (self.model?.status)!)!
            planButton?.dataStr = (self.model?.dataStr)!
            
            if model?.dataStr != "" {
                planButton?.indicator.isHidden = false
            } else {
                planButton?.indicator.isHidden = true
            }
            
            opinionIndicator(button: planButton!, text: (planButton?.dataStr)!)
            
            planButton?.resignFirstResponder()
        }
    }
    
    // MARK:- 系统函数
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        planButton = ColorfulButton(frame: self.bounds)
        
        self.contentView.addSubview(planButton!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 按钮备注标识与菜单名称
    fileprivate func opinionIndicator(button: ColorfulButton, text: String) {
        if text != "" {
            button.indicator.isHidden = false
            
            // 判断系统当前语言
            if isHanLanguage {
                button.remarksTitle = "编辑备注"
            } else {
                button.remarksTitle = "Edit Note"
            }
            
            button.reloadMenu()
        } else {
            
            // 判断系统当前语言
            if isHanLanguage {
                button.remarksTitle = "添加备注"
            } else {
                button.remarksTitle = "Add Note"
            }
            
            button.indicator.isHidden = true
            button.reloadMenu()
        }
    }
    
}
