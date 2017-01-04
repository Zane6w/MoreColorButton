//
//  ViewController.swift
//  MoreColorStatus
//
//  Created by zhi zhou on 2017/1/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

/// 状态枚举
enum StatusType {
    case Not   // 空值
    case Base  // 基本
    case Bad   // 差
    case Okay  // 还行
    case Good  // 好
    
    /// 枚举数组
    static let allValues = [Not, Base, Bad, Okay, Good]
}

class ViewController: UIViewController {
    // MARK:- 属性
    /// 用户点击按钮
    @IBOutlet weak var userButton: UIButton!
    
    /// 按钮背景颜色状态变量
    var buttonStatus: StatusType = .Base
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK:- 按钮点击事件
    @IBAction func changeButton(_ sender: UIButton) {
        // 状态判断与改变
        switch buttonStatus {
        case .Base:
            userButton.backgroundColor = .gray
        case .Bad:
            userButton.backgroundColor = .red
        case .Okay:
            userButton.backgroundColor = .yellow
        case .Good:
            userButton.backgroundColor = .green
        default:
            userButton.backgroundColor = .white
        }
        
        // 当前状态在枚举数组中的 index
        let currentIndex = StatusType.allValues.index(of: buttonStatus)
        
        // 枚举数组中最后一个元素的 index
        let option = StatusType.allValues.last!
        let lastIndex = StatusType.allValues.index(of: option)
        
        // 每次点击后都修改按钮的背景颜色状态为下一个, 以此来实现点击按钮切换多种背景颜色的效果
        if currentIndex! < lastIndex! {
            buttonStatus = StatusType.allValues[currentIndex! + 1]
        } else {
            buttonStatus = StatusType.allValues.first!
        }
    }

}

