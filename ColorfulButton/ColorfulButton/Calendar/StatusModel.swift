//
//  StatusModel.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/5.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class StatusModel: NSObject {
    // MARK:- 属性
    /// 按钮 ID
    var id: String?
    /// 按钮状态
    var status: String?
    /// 按钮数据
    var dataStr: String?
    /// 日期文字
    var dayStr: String?
    
    // MARK:- 自定义构造函数
    
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
}
