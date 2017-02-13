//
//  RemarksController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/20.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

enum RemarksType {
    /// 备注模式
    case remarks
    /// 添加新内容模式
    case add
}

class RemarksController: UIViewController {
    // MARK:- 属性
    let remarksView = UIView()
    
    typealias TapHandler = (RemarksController, String?) -> Void
    /// 按钮点击事件
    var cancelTapHandler: TapHandler?
    var pinTapHandler: TapHandler?
    
    /// 内容区域
    let textView = EditTextView(frame: .zero, textContainer: nil)
    /// 标题
    let titleLabel = UILabel()
    
    var style: RemarksType = .remarks
    
    // MARK:- 系统函数
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK:- 界面设置
extension RemarksController {
    /// 界面设置
    fileprivate func setupInterface() {
        view.backgroundColor = .clear
        setuprRemarksView()
        
        if textView.text != nil {
            textView.placeholderLabel.isHidden = true
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame(note:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc fileprivate func keyboardChangeFrame(note: Notification) {
        let keyboardBounds = note.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect
        let keyboardHeight = keyboardBounds.height
        // 根据键盘高度修正控件高度
        remarksView.frame.size.height = UIScreen.main.bounds.height - remarksView.frame.origin.y - keyboardHeight
        
        setupRemarksViewSubviews()
    }
    
    /// 设置备注页面
    fileprivate func setuprRemarksView() {
        let viewWidth = UIScreen.main.bounds.width - 20 * 2
        let viewHeight = UIScreen.main.bounds.height * 0.5
        let viewX = UIScreen.main.bounds.width - viewWidth - 20
        let viewY = (UIScreen.main.bounds.height - viewHeight) * 0.5
        remarksView.frame = CGRect(x: viewX, y: viewY, width: viewWidth, height: viewHeight)
        remarksView.backgroundColor = .white
        
        setupRemarksViewSubviews()
        view.addSubview(remarksView)
    }
    
    /// 设置备注页面子控件
    fileprivate func setupRemarksViewSubviews() {
        let splitLine = setSplitLine()
        setTextView(indicator: splitLine)
        setTitleLabel()
        setActionButton()
    }
    
    /// 操作按钮
    fileprivate func setActionButton() {
        // 取消
        let cancelSize = 18
        let cancelFrame = CGRect(x: 10, y: 12, width: cancelSize, height: cancelSize)

        // 添加备注
        let pinSize: CGFloat = 23
        let pinX = remarksView.bounds.width - 10 - pinSize
        let pinFrame = CGRect(x: pinX, y: 8, width: pinSize, height: pinSize)
        
        if style == .remarks {
            _ = addButton(frame: cancelFrame, title: nil, image: #imageLiteral(resourceName: "Cancel"), action: #selector(cancel))
            _ = addButton(frame: pinFrame, title: nil, image: #imageLiteral(resourceName: "Pin"), action: #selector(pin))
        } else {
            var cancelTitle = ""
            var pinTitle = ""
            if isChineseLanguage {
                cancelTitle = "取消"
                pinTitle = "添加"
            } else {
                cancelTitle = "Cancel"
                pinTitle = "Add"
            }
            let cancelButton = addButton(frame: cancelFrame, title: cancelTitle, image: nil, action: #selector(cancel))
            cancelButton.sizeToFit()
            
            let pinButton = addButton(frame: pinFrame, title: pinTitle, image: nil, action: #selector(pin))
            pinButton.sizeToFit()
        }
        
    }
    
    /// 创建添加按钮封装
    fileprivate func addButton(frame: CGRect, title: String?, image: UIImage?, action: Selector) -> UIButton {
        let actionButton = UIButton(type: .system)
        actionButton.setImage(image, for: .normal)
        actionButton.setTitle(title, for: .normal)
        actionButton.frame = frame
        actionButton.addTarget(self, action: action, for: .touchUpInside)
        remarksView.addSubview(actionButton)
        
        return actionButton
    }
    /* ---------- */
    /// 设置标题
    fileprivate func setTitleLabel() {
        // 判断系统当前语言
        let languages = Locale.preferredLanguages
        let currentLanguage = languages[0]
        
        // 判断是否是中文, 根据语言设置字体样式
        if currentLanguage.hasPrefix("zh") {
            if style == .remarks {
                titleLabel.text = "添加备注"
            } else {
                titleLabel.text = "新的规律"
            }
        } else {
            if style == .remarks {
                titleLabel.text = "Add Note"
            } else {
                titleLabel.text = "Add Regular"
            }
        }

        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.frame = .zero
        titleLabel.sizeToFit()
        let titleSize = titleLabel.frame.size
        let titleX = remarksView.bounds.width * 0.5 - titleSize.width * 0.5
        titleLabel.frame = CGRect(origin: CGPoint(x: titleX, y: 10), size: titleSize)
        remarksView.addSubview(titleLabel)
    }
    /* ---------- */
    /// 设置分割线
    fileprivate func setSplitLine() -> UIView {
        let SplitLine = UIView(frame: CGRect(x: 0, y: 40, width: remarksView.bounds.width, height: 0.5))
        SplitLine.backgroundColor = UIColor(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0)
        remarksView.addSubview(SplitLine)
        
        return SplitLine
    }
    /* ---------- */
}

// MARK:- 点击事件
extension RemarksController {
    /// 取消操作
    @objc fileprivate func cancel() {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        // 传递出去点击事件和参数
        if cancelTapHandler != nil {
            cancelTapHandler!(self, nil)
        }
    }
    
    /// 添加备注
    @objc fileprivate func pin() {
        textView.resignFirstResponder()
        //dismiss(animated: true, completion: nil)
        if pinTapHandler != nil {
            pinTapHandler!(self, textView.text)
        }
    }
    
}

// MARK:- TextView 相关
extension RemarksController: UITextViewDelegate {
    /// 设置 TextView
    fileprivate func setTextView(indicator: UIView) {
        textView.frame = CGRect(x: 0, y: indicator.frame.maxY + 1, width: remarksView.bounds.width, height: remarksView.bounds.height - indicator.frame.maxY - 8)
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        // 光标颜色
        textView.tintColor = UIColor(red: 88/255.0, green: 170/255.0, blue: 23/255.0, alpha: 1.0)
        
        textView.delegate = self
        
        if style == .remarks {
            textView.placeholderLabel.isHidden = true
        } else {
            if textView.text == "" {
                textView.placeholderLabel.isHidden = false
            }
        }
        
        remarksView.addSubview(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 监听文字的改变, 动态显示或隐藏占位文字
        self.textView.placeholderLabel.isHidden = textView.hasText
    }
    
}
