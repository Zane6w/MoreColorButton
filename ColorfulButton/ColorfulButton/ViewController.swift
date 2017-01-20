//
//  ViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/19.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK:- 属性
    @IBOutlet weak var colorBtn: ColorfulButton!
    var effectView: UIVisualEffectView?
    let remarksVC = RemarksController()
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()

        colorBtn.buttonTapHandler = { (button) in
            print(button.bgStatus)
        }
        
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK:- 界面设置
extension ViewController {
    fileprivate func setupInterface() {
        // 添加备注时, 显示蒙版
        colorBtn.remarksTapHandler = { (button) in
            print("remarks")
            self.setupBlur()
            UIView.animate(withDuration: 0.3, animations: {
                self.effectView?.alpha = 1.0
                self.remarksVC.modalPresentationStyle = .custom
                self.present(self.remarksVC, animated: true, completion: nil)
            })
        }
        
        // 取消备注后隐藏蒙版
        remarksVC.cancelTapHandler = { (vc) in
            UIView.animate(withDuration: 0.3) {
                self.effectView?.alpha = 0
            }
        }

    }
}

// MARK:- 手势相关
extension ViewController: UIGestureRecognizerDelegate {
    /// 点击菜单备注弹出窗口
    fileprivate func setupBlur() {
        let effect = UIBlurEffect(style: .dark)
        effectView = UIVisualEffectView(effect: effect)
        effectView?.frame = UIScreen.main.bounds
        effectView?.alpha = 0
        view.addSubview(effectView!)
        setupTapGesture(effectView!)
    }
    
    fileprivate func setupTapGesture(_ effectView: UIVisualEffectView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        tapGesture.delegate = self
        effectView.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func tap(tap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.effectView?.alpha = 0
        }
    }
    
}
