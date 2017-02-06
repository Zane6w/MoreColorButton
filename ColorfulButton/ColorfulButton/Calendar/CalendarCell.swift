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
            planButton?.resignFirstResponder()
        }
    }
    
    // MARK:- 系统函数
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        planButton = ColorfulButton(frame: self.bounds)

        self.contentView.addSubview(planButton!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
