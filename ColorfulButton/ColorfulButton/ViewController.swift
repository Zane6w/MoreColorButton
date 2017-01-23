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
    @IBOutlet weak var topBtn: ColorfulButton!
    @IBOutlet weak var bottomBtn: ColorfulButton!
    var btnArr = [ColorfulButton]()
    
    var chooseBtn: ColorfulButton?
    
    var effectView: UIVisualEffectView?
    //var remarksVC: RemarksController?
    
    /// 标记触发的按钮
    var sign: UIButton?
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        btnArr = [colorBtn, topBtn, bottomBtn]
        colorBtn.id = "111"
        topBtn.id = "222"
        bottomBtn.id = "333"

        for btn in btnArr {
            btn.buttonTapHandler = { (button) in
                if button.dataStr != nil {
                    _ = SQLite.shared.update(id: button.id!, status: "\(button.bgStatus)", remark: "\(button.dataStr!)", inTable: "t_buttons")
                } else {
                    _ = SQLite.shared.update(id: button.id!, status: "\(button.bgStatus)", remark: "", inTable: "t_buttons")
                }
            }
            
            let array = SQLite.shared.query(inTable: "t_buttons", id: btn.id!)
            if array?.count == 0 {
                if btn.dataStr != nil {
                    _ = SQLite.shared.insert(id: btn.id!, status: "\(btn.bgStatus)", remark: "\(btn.dataStr!)", inTable: "t_buttons")
                } else {
                    _ = SQLite.shared.insert(id: btn.id!, status: "\(btn.bgStatus)", remark: "", inTable: "t_buttons")
                }
            } else {
                let array = SQLite.shared.query(inTable: "t_buttons", id: btn.id!)
                print(array)
                let id = array?[0] as! String
                let status = array?[1] as! String
                let remark = array?[2] as! String
                print(status)
                if btn.id! == id {
                    let statusType = StatusType(rawValue: status)!
                    btn.bgStatus = statusType
                    
                    if remark != "" {
                        btn.indicator.isHidden = false
                        btn.remarksTitle = "编辑备注"
                        btn.reloadMenu()
                    } else {
                        btn.remarksTitle = "添加备注"
                        btn.indicator.isHidden = true
                        btn.reloadMenu()
                    }
                    
                    btn.dataStr = remark
                }
            }
            
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
        for btn in btnArr {
            let remarksVC = RemarksController()
            btn.remarksTapHandler = { (button) in
                self.setupBlur()
                self.chooseBtn = button
                
                if button.dataStr != nil {
                    remarksVC.textView.text = button.dataStr!
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.effectView?.alpha = 1.0
                    
                    remarksVC.modalPresentationStyle = .custom
                    self.present(remarksVC, animated: true, completion: nil)
                })
            }
            
            // 取消备注后隐藏蒙版
            remarksVC.cancelTapHandler = { (vc) in
                UIView.animate(withDuration: 0.3) {
                    self.effectView?.alpha = 0
                }
            }
            
            remarksVC.pinTapHandler = { (vc, text) in
                UIView.animate(withDuration: 0.3) {
                    self.effectView?.alpha = 0
                }
                
                self.chooseBtn?.dataStr = text!
                
                _ = SQLite.shared.update(id: (self.chooseBtn?.id)!, status: "\((self.chooseBtn?.bgStatus)!)", remark: text!, inTable: "t_buttons")
                
                if text != "", text != nil {
                    self.chooseBtn?.indicator.isHidden = false
                    self.chooseBtn?.remarksTitle = "编辑备注"
                    self.chooseBtn?.reloadMenu()
                } else {
                    self.chooseBtn?.remarksTitle = "添加备注"
                    self.chooseBtn?.indicator.isHidden = true
                    self.chooseBtn?.reloadMenu()
                }
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
