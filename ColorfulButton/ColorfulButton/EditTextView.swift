//
//  EditTextView.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class EditTextView: UITextView {
    // MARK:- 属性
    /// 占位文字
    lazy var placeholderLabel = UILabel()
    
    // MARK:- 函数
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupInterface() {
        placeholderLabel.textColor = .lightGray
        
        if isChineseLanguage {
            placeholderLabel.text = "名称"
        } else {
            placeholderLabel.text = "Name"
        }
        
        placeholderLabel.frame = CGRect(origin: CGPoint(x: 16, y: 8.25), size: .zero)
        placeholderLabel.sizeToFit()
        
        self.addSubview(placeholderLabel)
    }
    
}
