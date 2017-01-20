//
//  RemarksController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/20.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class RemarksController: UIViewController {
    // MARK:- 属性
    var remarksView = UIView()
    
    typealias TapHandler = (RemarksController) -> Void
    /// 按钮点击事件
    var cancelTapHandler: TapHandler?
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension RemarksController {
    fileprivate func setupInterface() {
        view.backgroundColor = .clear
        setuprRemarksView()
    }
    
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
    
    fileprivate func setupRemarksViewSubviews() {
        let cancelButton = addButton(title: "取消", action: #selector(cancel))
        let cancelSize = cancelButton.frame.size
        cancelButton.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: cancelSize)
        
        let saveButton = addButton(title: "保存", action: #selector(save))
        let saveSize = saveButton.frame.size
        let saveX = remarksView.bounds.width - 10 - saveSize.width
        saveButton.frame = CGRect(origin: CGPoint(x: saveX, y: 10), size: saveSize)
        
        let title = addButton(title: "添加备注", action: nil)
        title.isUserInteractionEnabled = false
        title.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        let titleSize = title.frame.size
        let titleX = remarksView.bounds.width * 0.5 - titleSize.width * 0.5
        title.frame = CGRect(origin: CGPoint(x: titleX, y: 10), size: titleSize)
        
        let indicatorView = UIView(frame: CGRect(x: 0, y: 40, width: remarksView.bounds.width, height: 0.5))
        indicatorView.backgroundColor = UIColor(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0)
        remarksView.addSubview(indicatorView)
        
        let textView = UITextView(frame: CGRect(x: 0, y: indicatorView.frame.maxY + 1, width: remarksView.bounds.width, height: remarksView.bounds.height - indicatorView.frame.maxY - 8))
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        // 光标颜色
        textView.tintColor = UIColor(red: 88/255.0, green: 170/255.0, blue: 23/255.0, alpha: 1.0)
        remarksView.addSubview(textView)
    }
    
    @objc fileprivate func cancel() {
        dismiss(animated: true, completion: nil)
        // 传递出去点击事件和参数
        if cancelTapHandler != nil {
            cancelTapHandler!(self)
        }
    }
    
    @objc fileprivate func save() {
        
    }
    
    /// 创建添加按钮封装
    fileprivate func addButton(title: String, image: UIImage? = nil, action: Selector?) -> UIButton {
        let actionButton = UIButton(type: .system)
        actionButton.setTitle(title, for: .normal)
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        actionButton.setImage(image, for: .normal)
        
        actionButton.frame = .zero
        actionButton.sizeToFit()
        actionButton.titleEdgeInsets = UIEdgeInsets(top: -12.5, left: 0, bottom: 0, right: 0)
        
        if action != nil {
            actionButton.addTarget(self, action: action!, for: .touchUpInside)
        }
        
        remarksView.addSubview(actionButton)
        
        return actionButton
    }

}







