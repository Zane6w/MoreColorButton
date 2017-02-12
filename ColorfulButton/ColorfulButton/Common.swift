//
//  Common.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// 应用特征颜色
let appColor = UIColor(red: 88/255.0, green: 170/255.0, blue: 23/255.0, alpha: 1.0)

/// 语言判断
var isChineseLanguage: Bool {
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

// MARK:- 通知名称

/// **将要** "退到桌面" 或 "多任务界面" 通知
let appWillResignActiveNotification = Notification.Name(rawValue: "appWillResignActive")

/// 后台模式（多任务选择了其他的 APP 或 回到了桌面）通知
let appDidEnterBackgroundNotification = Notification.Name(rawValue: "appDidEnterBackground")

/// 将要进入前台模式 通知
let appWillEnterForegroundNotification = Notification.Name(rawValue: "appWillEnterForeground")

/// 前台运行模式 通知
let appDidBecomeActiveNotification = Notification.Name(rawValue: "appDidBecomeActive")

/// 程序准备关闭
let appWillTerminateNotification = Notification.Name(rawValue: "appWillTerminate")
























