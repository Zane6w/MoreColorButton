////
////  ColorfulView.swift
////  Choose
////
////  Created by zhi zhou on 2017/2/5.
////  Copyright © 2017年 zhi zhou. All rights reserved.
////
//
//import UIKit
//
//enum StatusType: String {
//    /// 空值
//    case Null = "Null"
//    /// 基本
//    case Base = "Base"
//    /// 差
//    case Bad = "Bad"
//    /// 还行
//    case Okay = "Okay"
//    /// 好
//    case Good = "Good"
//    
//    /// 枚举数组
//    static let allValues = [Null, Base, Bad, Okay, Good]
//}
//
//class ColorfulView: UIView {
//    // MARK:- 属性
//    /// 颜色状态（默认：Base）
//    var status: StatusType = .Base {
//        didSet {
//            opinionStatus()
//        }
//    }
//    
//    /// 标识
//    var id: String?
//    
//    /// 数据
//    var dataStr: String?
//    
//    /// 内容
//    //let label = UILabel()
//    
//    /// 点击事件
//    typealias TapHandler = (ColorfulView) -> Void
//    var viewTapHandler: TapHandler?
//    var remarkTapHandler: TapHandler?
//    
//    /// 备注标题
//    var remarkTitle: String?
//    
//    /// 菜单控制器
//    fileprivate let menu = UIMenuController.shared
//    
//    /// 备注小圆点指示器
//    let indicator = UIView()
//    
//    /// 语言判断（判断是否为中文）
//    var isChinese: Bool {
//        let languages = Locale.preferredLanguages
//        let currentLanguage = languages[0]
//        
//        if currentLanguage.hasPrefix("zh") {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    // MARK:- 方法函数
//    
////    override func awakeFromNib() {
////        super.awakeFromNib()
////        initView()
////    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initView()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // 初始化 View
//    fileprivate func initView() {
////        label.frame = self.bounds
////        label.textColor = .white
////        label.textAlignment = .center
//////        label.isOpaque = true
////        label.layer.masksToBounds = true
////        
////        self.addSubview(label)
//        
//        self.layer.cornerRadius = self.bounds.width * 0.5
//        self.layer.masksToBounds = true
//        
//        if remarkTitle == nil {
//            isChinese == true ? (remarkTitle = "添加备注") : (remarkTitle = "Add Note")
//        }
//        
//        setupLongPressGesture()
//        setupMenuItems()
//        opinionStatus()
//        setRemarksIndicator()
//        
//    }
//    
//    /// 恢复按钮到初始化状态
//        func restore() {
//            self.status = .Base
//            self.dataStr = ""
//            self.indicator.isHidden = true
//        }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        // 点击时取消菜单的第一响应者并且隐藏菜单
//        self.resignFirstResponder()
//        menu.setMenuVisible(false, animated: true)
//        
//        // 当前状态在枚举数组中的 index
//        let currentIndex = StatusType.allValues.index(of: status)
//        
//        // 枚举数组中最后一个元素的 index
//        let option = StatusType.allValues.last!
//        let lastIndex = StatusType.allValues.index(of: option)
//        
//        // 每次点击后都修改按钮的背景颜色状态为下一个, 以此来实现点击按钮切换多种背景颜色的效果
//        if currentIndex! < lastIndex! {
//            status = StatusType.allValues[currentIndex! + 1]
//        } else {
//            status = StatusType.allValues.first!
//        }
//        
//        // 状态判断与改变
//        opinionStatus()
//        
//        // 传递出去点击事件和参数
//        if viewTapHandler != nil {
//            viewTapHandler!(self)
//        }
//        
//        opinionIndicatorColor()
//    }
//    
//}
//
//// MARK:- 手势
//extension ColorfulView: UIGestureRecognizerDelegate {
//    // 设置长按手势
//    fileprivate func setupLongPressGesture() {
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPress:)))
//        longPressGesture.delegate = self
//        self.addGestureRecognizer(longPressGesture)
//    }
//    
//    @objc fileprivate func longPress(longPress: UILongPressGestureRecognizer) {
//        // 长按手势按下和抬起会调用两次
//        if longPress.state == .began {
//            self.becomeFirstResponder()
//            
//            // 菜单显示位置
//            menu.setTargetRect(self.bounds, in: self)
//            
//            reloadMenu()
//            
//            // 显示菜单
//            menu.setMenuVisible(true, animated: true)
//        }
//    }
//    
//}
//
//// MARK:- 菜单设置
//extension ColorfulView {
//    func reloadMenu() {
//        setupMenuItems()
//    }
//    
//    fileprivate func setupMenuItems() {
//        var skipAction = UIMenuItem()
//        
//        var skipStr: String?
//        var undoStr: String?
//        var okStr: String?
//        var badStr: String?
//        
//        if isChinese {
//            skipStr = "跳过"
//            undoStr = "撤销跳过"
//            okStr = "一般"
//            badStr = "差评"
//        } else {
//            skipStr = "Skip"
//            undoStr = "Undo Skip"
//            okStr = "Ok"
//            badStr = "Bad"
//        }
//        
//        if status != .Null {
//            skipAction = UIMenuItem(title: skipStr!, action: #selector(skip))
//        } else {
//            skipAction = UIMenuItem(title: undoStr!, action: #selector(repealSkip))
//        }
//        
//        let okAction = UIMenuItem(title: okStr!, action: #selector(ok))
//        let badAction = UIMenuItem(title: badStr!, action: #selector(bad))
//        let remarksAction = UIMenuItem(title: remarkTitle!, action: #selector(remarks))
//        menu.menuItems = [skipAction, okAction, badAction, remarksAction]
//    }
//    
//    /* 菜单选项点击事件 */
//    @objc fileprivate func skip() {
//        chooseEvent(bgStatus: .Null)
//    }
//    
//    @objc fileprivate func repealSkip() {
//        chooseEvent(bgStatus: .Base)
//    }
//    
//    @objc fileprivate func ok() {
//        chooseEvent(bgStatus: .Okay)
//    }
//    
//    @objc fileprivate func bad() {
//        chooseEvent(bgStatus: .Bad)
//    }
//    
//    fileprivate func chooseEvent(bgStatus: StatusType) {
//        status = bgStatus
//        opinionStatus()
//        // 传递出去点击事件和参数
//        if viewTapHandler != nil {
//            viewTapHandler!(self)
//        }
//        opinionIndicatorColor()
//    }
//    
//    @objc fileprivate func remarks() {
//        // 传递出去点击事件和参数
//        if remarkTapHandler != nil {
//            remarkTapHandler!(self)
//        }
//        opinionIndicatorColor()
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        // 判断 action 中包含的各个事件的方法名称, 对比上了才能显示
//        if action == #selector(skip) || action == #selector(repealSkip) || action == #selector(ok) || action == #selector(bad) || action == #selector(remarks) {
//            return true
//        }
//        return false
//    }
//    
//}
//
//// MARK:- 备注小圆点
//extension ColorfulView {
//    // 设置备注小圆点指示器
//    fileprivate func setRemarksIndicator() {
//        let indicatorSize: CGFloat = 6
//        let indicatorX: CGFloat = self.bounds.width * 0.5 - indicatorSize * 0.5
//        let indicatorY: CGFloat = self.bounds.height - 10 - indicatorSize
//        indicator.frame = CGRect(x: indicatorX, y: indicatorY, width: indicatorSize, height: indicatorSize)
//        indicator.backgroundColor = .white
//        indicator.layer.cornerRadius = indicatorSize * 0.5
//        indicator.layer.masksToBounds = true
//        
//        indicator.isHidden = true
//        
//        self.addSubview(indicator)
//    }
//    
//}
//
//// MARK:- 颜色处理
//extension ColorfulView {
//    /// 动态判断标识颜色
//    fileprivate func opinionIndicatorColor() {
//        if status != .Null {
//            indicator.backgroundColor = .white
//        } else {
//            indicator.backgroundColor = setColor(red: 88, green: 170, blue: 23)
//        }
//    }
//    
//    /// 状态判断与颜色改变
//    fileprivate func opinionStatus() {
//        switch status {
//        case .Base:
//            changeColor(color: setColor(red: 154, green: 154, blue: 161))
//        case .Bad:
//            changeColor(color: setColor(red: 255, green: 90, blue: 95))
//        case .Okay:
//            changeColor(color: setColor(red: 246, green: 212, blue: 49))
//        case .Good:
//            changeColor(color: setColor(red: 128, green: 192, blue: 81))
//        default:
//            changeColor(color: .white)
//        }
//    }
//    
//    /// 改变背景颜色
//    fileprivate func changeColor(color: UIColor, duration: TimeInterval = 0.1) {
//        UIView.animate(withDuration: duration) {
//            self.backgroundColor = color
//            //self.label.backgroundColor = color
//        }
//    }
//    
//    /// 生成颜色（默认不透明）
//    fileprivate func setColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
//        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
//    }
//    
//    /// 生成颜色（相同的 RGB 值, 默认不透明）
//    fileprivate func setColor(sameRGB: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
//        return UIColor(red: sameRGB/255.0, green: sameRGB/255.0, blue: sameRGB/255.0, alpha: alpha)
//    }
//    
//}
//
//
//
//
//
//
//
//
//
//
