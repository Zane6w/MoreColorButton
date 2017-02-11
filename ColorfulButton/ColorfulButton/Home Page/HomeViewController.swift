//
//  HomeViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

private let contentIdentifier = "contentCell"

class HomeViewController: UIViewController {
    // MARK:- 属性
    var tableView: UITableView?
    
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
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
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: contentIdentifier, for: indexPath) as! ContentCell
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = CalendarViewController()
        
        detailController.title = "ceshi"
        
        navigationController?.pushViewController(detailController, animated: true)
    }
    
}

// MARK:- 导航栏设置
extension HomeViewController {
    
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
        
        let editRegularItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRegular))
        editRegularItem.style = .plain
        
        let addNewRegularItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRegular))
        addNewRegularItem.style = .plain
        
        navigationItem.leftBarButtonItem = editRegularItem
        navigationItem.rightBarButtonItem = addNewRegularItem
        
    }
    
    @objc fileprivate func editRegular() {
        print("edit")
    }
    
    @objc fileprivate func addNewRegular() {
        print("add")
    }
    
}




































