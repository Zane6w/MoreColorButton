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
    
    /// 标题数组
    var titles = [String]()
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupWeekTitleView()
        
        loadTitleData()
        
        _ = opinionEditStatus()
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
        tableView?.separatorInset = .zero
        tableView?.separatorColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8941176471, alpha: 1)
    
        tableView?.tableFooterView = UIView()
        
        self.view.addSubview(tableView!)
        
        tableView?.register(ContentCell.self, forCellReuseIdentifier: contentIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: contentIdentifier, for: indexPath) as! ContentCell
        
        cell.titleStr = titles[indexPath.row]
        
        cell.controller = self
        
        cell.selectionStyle = .none
        
        tableView.rowHeight = cell.cellHeight
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = CalendarViewController()
        
        detailController.title = titles[indexPath.row]
        
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let thisYear = Calendar.current.component(.year, from: Date())

            _ = SQLite.shared.delete(id: "\(titles[indexPath.row])#\(thisYear)", inTable: regularDataBase)
            _ = SQLite.shared.delete(title: titles[indexPath.row], inTable: regularDataBase)
            
            titles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let isEnabled = opinionEditStatus()
            editButtonChange(isEnabled: isEnabled)
            
            if titles.count == 0 {
                tableView.setEditing(false, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if isChineseLanguage {
            return "删除"
        } else {
            return "Delete"
        }
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
        if isChineseLanguage {
            editButton.setTitle("编辑", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
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
        
        _ = opinionEditStatus()
    }
    
    @objc fileprivate func editRegular() {
        tableView?.setEditing(!(tableView?.isEditing)!, animated: true)
        
        editButtonChange(isEnabled: true)
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
                    _ = self.opinionEditStatus()
                })
            }
        }
        
    }
    
    /// 判断左上角编辑按钮是否可用
    fileprivate func opinionEditStatus() -> Bool {
        if titles.count == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
            return false
        } else {
            navigationItem.leftBarButtonItem?.isEnabled = true
            return true
        }
    }
    
    /// 左上角编辑按钮状态改变判断
    fileprivate func editButtonChange(isEnabled: Bool) {
        let editButton = navigationItem.leftBarButtonItem?.customView as! UIButton
        
        if (tableView?.isEditing)! {
            editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            if isChineseLanguage {
                editButton.setTitle("完成", for: .normal)
            } else {
                editButton.setTitle("Done", for: .normal)
            }
        } else {
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            if isChineseLanguage {
                editButton.setTitle("编辑", for: .normal)
            } else {
                editButton.setTitle("Edit", for: .normal)
            }
        }
        
        if isEnabled {
            
        } else {
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            if isChineseLanguage {
                editButton.setTitle("编辑", for: .normal)
            } else {
                editButton.setTitle("Edit", for: .normal)
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
