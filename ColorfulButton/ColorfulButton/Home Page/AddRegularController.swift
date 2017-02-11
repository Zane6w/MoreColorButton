//
//  AddRegularController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class AddRegularController: UIViewController {
    // MARK:- 属性
    let newRegularView = UIView()
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK:- 界面设置
extension AddRegularController {
    
    fileprivate func setupInterface() {
        self.view.backgroundColor = .clear
        
    }
    
}

























