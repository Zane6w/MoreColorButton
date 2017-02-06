//
//  EventManager.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class EventManager: NSObject {
    // MARK:- 属性
    /// EventManager 单例
    static let shared = EventManager()
    
    fileprivate var selectedButton: ColorfulButton?
    
    fileprivate var effectView: UIVisualEffectView?
    
    fileprivate var tempViewController: UIViewController?
    
    var dataCache = [String: Any]()
    
    /// 语言判断
    fileprivate var isHanLanguage: Bool {
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
    
    // MARK:- 方法函数
    
    /// 存取按钮状态
    /// - parameter button: 初始化的按钮
    func accessButton(button: ColorfulButton) {
        // 按钮点击事件
        button.buttonTapHandler = { (operatingButton) in

            if operatingButton.dataStr != nil {
                _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "\(operatingButton.dataStr!)", inTable: tableName)
            } else {
                _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "", inTable: tableName)
            }
        }
        
        // 按钮所有状态参数的存取
        let dataArray = SQLite.shared.query(inTable: tableName, id: button.id!)
        if dataArray?.count == 0 {
            // 新的按钮要初始化状态, 防止 cell 复用导致的数据混乱.
            button.restore()
            if button.dataStr != nil {
                _ = SQLite.shared.insert(id: button.id!, status: "\(button.bgStatus)", remark: "\(button.dataStr!)", inTable: tableName)
            } else {
                _ = SQLite.shared.insert(id: button.id!, status: "\(button.bgStatus)", remark: "", inTable: tableName)
            }
        } else {
//            let dataArray = SQLite.shared.query(inTable: tableName, id: button.id!)
            
            let id = dataArray?[0] as! String
            let status = dataArray?[1] as! String
            let remark = dataArray?[2] as! String
            
            if button.id! == id {
                let statusType = StatusType(rawValue: status)!
                button.bgStatus = statusType
                
                opinionIndicator(button: button, text: remark)
                
                button.dataStr = remark
            }
        }
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
