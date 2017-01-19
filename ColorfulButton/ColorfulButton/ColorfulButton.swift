//
//  ColorfulButton.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/19.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// 按钮背景颜色状态枚举
enum StatusType {
    /// 空值
    case Null
    /// 基本
    case Base
    /// 差
    case Bad
    /// 还行
    case Okay
    /// 好
    case Good
    
    /// 枚举数组
    static let allValues = [Null, Base, Bad, Okay, Good]
}

class ColorfulButton: UIButton, UIGestureRecognizerDelegate {
    // MARK:- 属性
    /// 按钮背景颜色状态（默认: Base）
    var bgStatus: StatusType = .Base
    
    typealias TapHandler = (ColorfulButton) -> Void
    /// 按钮点击事件
    var buttonTapHandler: TapHandler?
    
    let menu = UIMenuController.shared
    
    // MARK:- 方法
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLongPress()
        setupMenuItems()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // 点击时取消菜单的第一响应者并且隐藏菜单
        self.resignFirstResponder()
        menu.setMenuVisible(false, animated: true)
        
        // 传递出去点击事件和参数
        if buttonTapHandler != nil {
            buttonTapHandler!(self)
        }
        
        // 状态判断与改变
        switch bgStatus {
        case .Base:
            changeColor(color: setColor(red: 154, green: 154, blue: 161))
        case .Bad:
            changeColor(color: setColor(red: 255, green: 90, blue: 95))
        case .Okay:
            changeColor(color: setColor(red: 246, green: 212, blue: 49))
        case .Good:
            changeColor(color: setColor(red: 128, green: 192, blue: 81))
        default:
            changeColor(color: .white)
        }
        
        // 当前状态在枚举数组中的 index
        let currentIndex = StatusType.allValues.index(of: bgStatus)
        
        // 枚举数组中最后一个元素的 index
        let option = StatusType.allValues.last!
        let lastIndex = StatusType.allValues.index(of: option)
        
        // 每次点击后都修改按钮的背景颜色状态为下一个, 以此来实现点击按钮切换多种背景颜色的效果
        if currentIndex! < lastIndex! {
           bgStatus = StatusType.allValues[currentIndex! + 1]
        } else {
           bgStatus = StatusType.allValues.first!
        }
    }
    
    // MARK:- 颜色处理
    /// 改变背景颜色
    /// - parameter color: 传入需要改变的颜色
    /// - parameter duration: 改变颜色动画所需时间（默认: 0.1s）
    fileprivate func changeColor(color: UIColor, duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration) {
            self.backgroundColor = color
        }
    }

    /// 生成颜色（默认不透明）
    fileprivate func setColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    /// 生成颜色（相同的 RGB 值, 默认不透明）
    fileprivate func setColor(sameRGB: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: sameRGB/255.0, green: sameRGB/255.0, blue: sameRGB/255.0, alpha: alpha)
    }
    
    // MARK:- 长按手势及其处理
    /// 添加长按手势
    fileprivate func setupLongPress() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPress:)))
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc fileprivate func longPress(longPress: UILongPressGestureRecognizer) {
        // 长按手势按下和抬起会调用两次
        if longPress.state == .began {
            print("longPress")
            self.becomeFirstResponder()
            
            // 菜单显示位置
            menu.setTargetRect(self.bounds, in: self)
            
            // 显示菜单
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    // MARK:- 菜单相关设置
    /// 自定义菜单的选项
    fileprivate func setupMenuItems() {
        let skipAction = UIMenuItem(title: "跳过", action: #selector(actionAll))
        let okAction = UIMenuItem(title: "还行", action: #selector(actionAll))
        let badAction = UIMenuItem(title: "差评", action: #selector(actionAll))
        let remarksAction = UIMenuItem(title: "备注", action: #selector(actionAll))
        menu.menuItems = [skipAction, okAction, badAction, remarksAction]
    }
    
    @objc fileprivate func actionAll() {
        print("菜单显示")
    }
    
    // 让按钮具备成为第一响应者的资格
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // 返回悬浮菜单中可以显示的选项
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 判断 action 中包含的各个事件的方法名称, 对比上了才能显示
        if action == #selector(actionAll) {
            return true
        }
        return false
    }
    
}
