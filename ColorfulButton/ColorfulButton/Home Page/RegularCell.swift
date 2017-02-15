//
//  RegularCell.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class RegularCell: UICollectionViewCell {
    // MARK:- 属性
    // 按钮
    var regularButton: ColorfulButton?
    
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
    
    // MARK:- 系统函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupButton() {
        regularButton = ColorfulButton(frame: self.bounds)
        regularButton?.bgStatus = .Good
        
        self.contentView.addSubview(regularButton!)
    }
    
}
