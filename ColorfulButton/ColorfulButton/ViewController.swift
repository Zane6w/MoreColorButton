//
//  ViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/1/19.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var colorBtn: ColorfulButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorBtn.buttonTapHandler = { (button) in
            print(button.bgStatus)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

