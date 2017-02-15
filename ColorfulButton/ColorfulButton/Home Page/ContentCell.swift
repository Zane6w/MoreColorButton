//
//  ContentCell.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/11.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

private let regularIdentifier = "regularCollectionCell"

class ContentCell: UITableViewCell {
    // MARK:- 属性
    
    var controller: HomeViewController?
    
    /// 标题
    let identifyLabel = UILabel()
    
    let disclosureIndicator = UIImageView()
    
    var collectionView: UICollectionView?
    
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    let thisYear = Calendar.current.component(.year, from: Date())
    /// 7 个按钮的 ID
    var ids = [String]()
    
    var titles = [String]()
    
    var statusCache = [String: Any]()
    var dataStrCache = [String: Any]()
    
    var effectView: UIVisualEffectView?
    var chooseBtn: ColorfulButton?
    
    /// 一行有几个 Cell
    fileprivate let numberOfOneRow = 7
    /// **collectionView** 每个 **cell** 上下左右的间距
    fileprivate let itemSpace: CGFloat = 3
    
    var cellHeight: CGFloat = 0
    
    var titleStr: String? {
        didSet {
            setupIdentifyLabel()
            setupCollectionView()
            setupDisclosureIndicator()
            
            cellHeight = identifyLabel.bounds.height + (collectionView?.bounds.height)! + 6
            loadData()
            setupNotification()
        }
    }
    
    // MARK:- 系统函数
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- 初始化属性
    fileprivate func setupIdentifyLabel() {
        identifyLabel.text = titleStr!
        identifyLabel.font = UIFont.systemFont(ofSize: 17)
        identifyLabel.textAlignment = .left
        
        identifyLabel.frame = CGRect(x: 16, y: 0, width: self.bounds.width, height: 36)
        
        self.contentView.addSubview(identifyLabel)
    }
    
    /// 设置详情指示器
    fileprivate func setupDisclosureIndicator() {
        let indicatorHeight: CGFloat = 13
        let indicatorX: CGFloat = UIScreen.main.bounds.width - 23
        let indicatorY: CGFloat = identifyLabel.bounds.height * 0.5 - indicatorHeight * 0.5
        disclosureIndicator.frame = CGRect(x: indicatorX, y: indicatorY, width: 8, height: indicatorHeight)
        disclosureIndicator.image = #imageLiteral(resourceName: "disclosureIndicator")
        
        self.contentView.addSubview(disclosureIndicator)
    }

}

// MARK:- collectionView 相关
extension ContentCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate func setupCollectionView() {
        let oneItemSize: CGFloat = UIScreen.main.bounds.width / CGFloat(numberOfOneRow) - itemSpace * 2
        
        let frame = CGRect(x: 0, y: identifyLabel.frame.maxY, width: UIScreen.main.bounds.width, height: oneItemSize)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        // 每个 Cell 的尺寸
        let itemSize = CGSize(width: oneItemSize, height: oneItemSize)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = itemSpace
        flowLayout.minimumInteritemSpacing = itemSpace
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: itemSpace, bottom: 0, right: itemSpace)
        
        self.contentView.addSubview(collectionView!)
        
        collectionView?.register(RegularCell.self, forCellWithReuseIdentifier: regularIdentifier)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        self.cellHeight = identifyLabel.bounds.height + (collectionView?.bounds.height)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfOneRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: regularIdentifier, for: indexPath) as! RegularCell
        
        cell.regularButton?.becomeFirstResponder()
        cell.regularButton?.resignFirstResponder()
        
        cell.regularButton?.id = ids[indexPath.row]
        
        cell.regularButton?.setTitle(titles[indexPath.row], for: .normal)
        
        cell.regularButton?.buttonTapHandler = { (operatingButton) in
            // 设置按钮状态颜色
            self.statusCache["\((operatingButton.id)!)"] = operatingButton.bgStatus.rawValue
            
            self.opinionDate(operatingButton, isLongPress: false)
        }
        
        // 按钮长按手势事件
        cell.regularButton?.longPressHandler = { (operatingButton) in
            self.opinionDate(operatingButton, isLongPress: true)
        }
        
        /* ---------- */
        // 设置按钮状态颜色
        if statusCache["\((cell.regularButton?.id)!)"] == nil {
            cell.regularButton?.bgStatus = .Base
            statusCache["\((cell.regularButton?.id)!)"] = "Base"
        } else {
            let statusStr = statusCache["\((cell.regularButton?.id)!)"] as! String
            cell.regularButton?.bgStatus = StatusType(rawValue: statusStr)!
        }
        /* ---------- */
        // 备注相关设置
        if dataStrCache["\((cell.regularButton?.id)!)"] == nil {
            dataStrCache["\((cell.regularButton?.id)!)"] = ""
        } else {
            cell.regularButton?.dataStr = (dataStrCache["\((cell.regularButton?.id)!)"] as! String)
        }
        
        // 备注小圆点指示器判断
        if cell.regularButton?.dataStr != nil {
            opinionIndicator(button: (cell.regularButton)!, text: (cell.regularButton?.dataStr)!)
        }
        /* ---------- */
        DispatchQueue.main.async {
            self.setupInterface(btn: cell.regularButton!)
        }
        
        return cell
    }
    
}

// MARK:- 数据处理
extension ContentCell {
    
    fileprivate func loadData() {
        let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((identifyLabel.text)!)#\(thisYear)")
        
        if let dataArray = dataArray, dataArray.count != 0 {
            let statusDict = dataArray[1] as! [String: Any]
            let remarksDict = dataArray[2] as! [String: Any]
            
            self.statusCache = statusDict
            self.dataStrCache = remarksDict
        }
        
        
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        
        var ids = [String]()
        var titles = [String]()
        for i in 0..<7 {
            let dateTuple = DateTool.shared.processMonthAndDay(month: month, day: day - i)
            
            let str = "\((identifyLabel.text)!)#\(thisYear)\(dateTuple.monthStr)\(dateTuple.dayStr)"
            ids.append(str)
            
            titles.append("\(day - i)")
        }
        
        ids.reverse()
        titles.reverse()
        
        self.ids = ids
        self.titles = titles
    }
    
}

// MARK:- 日期相关
extension ContentCell {
    
    /// 日期判断
    /// - 判断点击的日期是否是未来日期
    /// - 未来日期不可选择，不会保存，同时震动提示。
    /// - parameter operatingButton: 点击的按钮
    /// - parameter isLongPress: 是否为长按操作
    fileprivate func opinionDate(_ operatingButton: ColorfulButton, isLongPress: Bool) {
        if isLongPress {
            operatingButton.menu.setMenuVisible(true, animated: true)
        } else {
            operatingButton.menu.setMenuVisible(false, animated: true)
        }
        
        let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((identifyLabel.text)!)#\(self.thisYear)")
        if let dataArray = dataArray, dataArray.count != 0 {
            let statusDict = dataArray[1] as! [String: Any]
            if statusDict["\((operatingButton.id)!)"] == nil {
                _ = SQLite.shared.insert(id: "\((identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
            } else {
                _ = SQLite.shared.update(id: "\((identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
            }
        } else {
            _ = SQLite.shared.insert(id: "\((identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
        }
    }

    
    
}

// MARK:- 备注界面相关
extension ContentCell {
    
    fileprivate func setupInterface(btn: ColorfulButton) {
        btn.remarksTapHandler = { (button) in
            self.setupBlur()
            self.chooseBtn = button
            let remarksVC = RemarksController()
            
            if button.dataStr != nil {
                remarksVC.textView.text = button.dataStr!
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                remarksVC.modalPresentationStyle = .custom
                self.controller?.present(remarksVC, animated: true, completion: nil)
                self.controller?.navigationController?.navigationBar.isHidden = true
                self.effectView?.alpha = 1.0
            })
            
            // 取消备注后隐藏蒙版
            remarksVC.cancelTapHandler = { (_) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.effectView?.alpha = 0
                }, completion: { (_) in
                    self.controller?.navigationController?.navigationBar.isHidden = false
                })
            }
            
            remarksVC.pinTapHandler = { (_, text) in
                self.controller?.dismiss(animated: true, completion: nil)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.effectView?.alpha = 0
                }, completion: { (_) in
                    self.controller?.navigationController?.navigationBar.isHidden = false
                })
                
                // 添加到缓存
                self.dataStrCache["\((self.chooseBtn?.id)!)"] = text!
                
                self.chooseBtn?.dataStr = text!
                
                let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((self.identifyLabel.text)!)#\(self.thisYear)")
                if let dataArray = dataArray, dataArray.count != 0 {
                    let remarksDict = dataArray[2] as! [String: Any]
                    if remarksDict["\((self.chooseBtn?.id)!)"] == nil {
                        _ = SQLite.shared.insert(id: "\((self.identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                    } else {
                        _ = SQLite.shared.update(id: "\((self.identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                    }
                } else {
                    _ = SQLite.shared.insert(id: "\((self.identifyLabel.text)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                }
                
                if let text = text, let chooseBtn = self.chooseBtn {
                    self.opinionIndicator(button: chooseBtn, text: text)
                }
            }
            
        }
    }
    
    /// 按钮备注标识与菜单名称
    fileprivate func opinionIndicator(button: ColorfulButton, text: String) {
        if text != "" {
            button.indicator.isHidden = false
            
            // 判断系统当前语言
            if isChineseLanguage {
                button.remarksTitle = "编辑备注"
            } else {
                button.remarksTitle = "Edit Note"
            }
            
            button.reloadMenu()
        } else {
            
            // 判断系统当前语言
            if isChineseLanguage {
                button.remarksTitle = "添加备注"
            } else {
                button.remarksTitle = "Add Note"
            }
            
            button.indicator.isHidden = true
            button.reloadMenu()
        }
    }
    
    /// 点击菜单备注弹出窗口背景添加蒙版
    fileprivate func setupBlur() {
        let effect = UIBlurEffect(style: .dark)
        effectView = UIVisualEffectView(effect: effect)
        effectView?.frame = UIScreen.main.bounds
        effectView?.alpha = 0
        controller?.view.addSubview(effectView!)
    }
    
}

// MARK:- 通知相关
extension ContentCell {
    
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: timeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: detailUpdateNotification, object: nil)
    }
    
    @objc fileprivate func update() {
        loadData()
        collectionView?.reloadData()
    }
    
}
