//
//  HomeViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit
import AudioToolbox

private let contentIdentifier = "contentCell"

class HomeViewController: UIViewController {
    // MARK:- 属性
    var tableView: UITableView?
    
    let weekTitleView = WeekView()
    
    var effectView: UIVisualEffectView?
    
    /// 规律数据库
    var regularData = [Any]()
    
    /// 标题数组
    var titles = [String]()
    
    var statusCache = [String: Any]()
    var dataStrCache = [String: Any]()
    let year = 2017
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupWeekTitleView()
        
        loadTitleData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK:- tableView 相关
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate func setupTableView() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        
        self.view.addSubview(tableView!)
        
        tableView?.register(ContentCell.self, forCellReuseIdentifier: contentIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: contentIdentifier, for: indexPath) as! ContentCell

        if titles.count != 0 {
            cell.identifyLabel.text = titles[indexPath.row]
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = CalendarViewController()
        
        detailController.title = titles[indexPath.row]
        
        navigationController?.pushViewController(detailController, animated: true)
    }
    
}

// MARK:- 导航栏设置
extension HomeViewController: CAAnimationDelegate {
    
    fileprivate func setupNavigationBar() {
        let naviBar = navigationController?.navigationBar
        let naviBarBottomLine = naviBar?.subviews.first?.subviews.first
        
        if (naviBarBottomLine?.isKind(of: UIImageView.self))! {
            // 隐藏导航栏底部的黑色细线
            naviBarBottomLine?.isHidden = true
        }
        
        setupNavigationItem()
    }
    
    fileprivate func setupNavigationItem() {
        if isChineseLanguage {
            self.title = "规律"
        } else {
            self.title = "Regular"
        }
        
        // -----------------
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        editButton.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width / 7, height: (navigationController?.navigationBar.bounds.height)!))
        editButton.tintColor = appColor
        
        editButton.contentVerticalAlignment = .center
        editButton.contentHorizontalAlignment = .left
        
        editButton.addTarget(self, action: #selector(editRegular), for: .touchUpInside)
        
        let editRegularItem = UIBarButtonItem(customView: editButton)
        
        navigationItem.leftBarButtonItem = editRegularItem
        
        // -----------------
        
        let addNewRegularItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRegular))
        addNewRegularItem.style = .plain
        
        navigationItem.rightBarButtonItem = addNewRegularItem
        
    }
    
    @objc fileprivate func editRegular() {
        print("edit")
    }
    
    @objc fileprivate func addNewRegular() {
        let remarksVC = RemarksController()
        remarksVC.style = .add
        
        setupBlur()
        
        UIView.animate(withDuration: 0.3, animations: {
            remarksVC.modalPresentationStyle = .custom
            self.present(remarksVC, animated: true, completion: nil)
            self.navigationController?.navigationBar.isHidden = true
            self.effectView?.alpha = 1.0
        })
        
        // 取消备注后隐藏蒙版
        remarksVC.cancelTapHandler = { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.effectView?.alpha = 0
            }, completion: { (_) in
                self.navigationController?.navigationBar.isHidden = false
            })
        }

        remarksVC.pinTapHandler = { (controller, text) in
            if text! == "" {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.shake(view: controller.remarksView)
            } else {
                // 添加数据
                self.loadTitleData(title: text!)
                
                self.dismiss(animated: true, completion: nil)
                UIView.animate(withDuration: 0.3, animations: {
                    self.effectView?.alpha = 0
                }, completion: { (_) in
                    self.navigationController?.navigationBar.isHidden = false
                })
            }
        }
        
    }
    
    fileprivate func setupBlur() {
        let effect = UIBlurEffect(style: .dark)
        effectView = UIVisualEffectView(effect: effect)
        effectView?.frame = UIScreen.main.bounds
        effectView?.alpha = 0
        view.addSubview(effectView!)
    }
    
    /// 左右晃动动画
    fileprivate func shake(view: UIView) {
        let shakeAnimation = CAKeyframeAnimation()
        shakeAnimation.keyPath = "transform.translation.x"
        // 偏移量
        let offset = 5
        // 过程
        shakeAnimation.values = [-offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0]
        // 动画时间
        shakeAnimation.duration = 0.3
        // 执行次数
        shakeAnimation.repeatCount = 1
        // 切出此界面再回来动画不会停止
        shakeAnimation.isRemovedOnCompletion = true
        shakeAnimation.delegate = self
        
        view.layer.add(shakeAnimation, forKey: "shake")
    }
    
    fileprivate func setupWeekTitleView() {
        weekTitleView.frame = CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: UIScreen.main.bounds.width, height: 30)
        weekTitleView.sorted = .Right
        weekTitleView.firstWorkday = 0
        
        self.view.addSubview(weekTitleView)
        
        tableView?.contentInset = UIEdgeInsets(top: weekTitleView.bounds.height, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK:- 数据相关
extension HomeViewController {    
    /// 加载标题数据
    fileprivate func loadTitleData(title: String? = nil) {
        if title == nil {
            let titleArray = SQLite.shared.queryAllTitle(inTable: regularDataBase)
            if titleArray != nil, titleArray?.count != 0 {
                var titles = titleArray!
                titles.reverse()
                self.titles = titles as! [String]
            }
        } else {
            _ = SQLite.shared.insert(title: title!, inTable: regularDataBase)
            self.titles.insert(title!, at: 0)
        }
        tableView?.reloadData()
    }
 
}


































