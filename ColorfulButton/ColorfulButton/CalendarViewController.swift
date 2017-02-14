//
//  CalendarViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit
import AudioToolbox

private let collectionCellIdentifier = "collectionCell"
private let headerIdentifier = "headerCell"
private let footerIdentifier = "footerCell"
private let normalCell = "normalCell"

class CalendarViewController: UIViewController {
    // MARK:- 属性
    
    fileprivate let layout = UICollectionViewFlowLayout()
    fileprivate var collectionView: UICollectionView?
    /// 头部高度
    fileprivate let headerHeight: CGFloat = 30
    /// 尾部高度
    fileprivate let footerHeight: CGFloat = 40
    
    /// **collectionView** 每个 **cell** 上下左右的间距
    fileprivate let cellItemSpace: CGFloat = 3
    /// 每行 **cell** 个数
    fileprivate let itemsNumber: CGFloat = 7
    
    let weekTitleView = WeekView()
    
    var chooseBtn: ColorfulButton?
    
    var effectView: UIVisualEffectView?
    /// 月份标识数组
    fileprivate var months = [String]()
    /// /// 首个工作日（默认星期日: 0）
    /// - 周日、 周一 ~ 周六标识: 0、1 ~ 6
    var firstWeekday = 0
    
    var naviTitle = ""
    
    /// 年份（可根据年份前缀来赋值按钮 ID，可用来查询旧数据）
    /// ID
    var regularID: String?
    /// 今年
    let thisYear = Calendar.current.component(.year, from: Date())
    
    let dayOfMonth = DateTool.shared.getDayOfMonth()
    let firstdayOfWeek = DateTool.shared.getFirstMonthDayOfWeek()
    
    var statusCache = [String: Any]()
    var dataStrCache = [String: Any]()
    var todayStr = ""
    var calendarTimer: Timer?
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((self.title)!)#\(thisYear)")
        
        if let dataArray = dataArray, dataArray.count != 0 {
            let statusDict = dataArray[1] as! [String: Any]
            let remarksDict = dataArray[2] as! [String: Any]
            
            self.statusCache = statusDict
            self.dataStrCache = remarksDict
        }
        
        // 今天的日期 ID
        let date = DateTool.shared.getCompactDate(dateFormat: "MMdd")
        let todayID = "\(date)"
        self.todayStr = todayID
        
        weekTitleView.frame = CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: UIScreen.main.bounds.width, height: 30)

        setupInterface()
        
        naviTitle = self.title!
        
        weekTitleView.firstWorkday = self.firstWeekday
        
        self.view.addSubview(weekTitleView)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        collectionView?.register(CalendarCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: normalCell)
        
        setupNotification()
    }
    
    // 所有子控件都加载完毕
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToThisMonth()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        weekTitleView.weekViewTimer?.invalidate()
        todayIndicatorTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK:- 界面设置
    fileprivate func setupInterface() {
        // 右上角年份标识
        let yearButton = UIButton(type: .system)
        yearButton.setTitle("\(Calendar.current.component(.year, from: Date()))", for: .normal)
        yearButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        yearButton.sizeToFit()
        yearButton.isSelected = true
        yearButton.tintColor = UIColor(red: 88/255.0, green: 170/255.0, blue: 23/255.0, alpha: 1.0)
        yearButton.isOpaque = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: yearButton)
        
        
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        
        collectionView?.contentInset = UIEdgeInsets(top: weekTitleView.bounds.height, left: 0, bottom: -footerHeight, right: 0)
        
        // 每个cell的尺寸
        let oneItemSize: CGFloat = (collectionView?.bounds.width)! / itemsNumber - cellItemSpace * 2
        let itemSize = CGSize(width: oneItemSize, height: oneItemSize)
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = cellItemSpace // 左右间隔
        layout.minimumLineSpacing = cellItemSpace // 上下间隔
        // 页眉的尺寸
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: cellItemSpace, bottom: 0, right: cellItemSpace)
        
        view.addSubview(collectionView!)
        
        
        if isChineseLanguage {
            for i in 1...12 {
                months.append("\(i)月")
            }
        } else {
            months = ["January", "February", " March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        }
    }
    
}

// MARK:- collectionView 数据源、代理方法
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 每月的第一天是星期几？ 周日、 周一 ~ 周六标识: 0、1 ~ 6
        let firstday = firstdayOfWeek[section]
        
        // 这个月的第一天是星期天, 并且星期显示方式为"周日首个工作日"
        if firstday == 0 {
            if firstWeekday == 0 {
                return dayOfMonth[section]
            } else {
                return dayOfMonth[section] + (Int(itemsNumber) - firstWeekday)
            }
        } else {
            // 这个月的第一天不是星期天
            if firstWeekday == 0 {
                return dayOfMonth[section] + firstday
            } else {
                if firstday >= firstWeekday {
                    return dayOfMonth[section] + firstday - firstWeekday
                } else {
                    return dayOfMonth[section] + firstday + (Int(itemsNumber) - firstWeekday)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 每月的第一天是星期几？ 周日、 周一 ~ 周六标识: 0、1 ~ 6
        let firstday = firstdayOfWeek[indexPath.section]
        
        if firstWeekday == 0 {
            if firstday == 0 {
                return createCalendarCell(collectionView, indexPath, row: indexPath.row)
            } else {
                if indexPath.row < firstday {
                    return createBlankCell(collectionView, indexPath)
                } else {
                    return createCalendarCell(collectionView, indexPath, row: indexPath.row - firstday)
                }
            }
        } else {
            if firstday == 0 {
                if indexPath.row < (Int(itemsNumber) - firstWeekday) {
                    return createBlankCell(collectionView, indexPath)
                } else {
                    return createCalendarCell(collectionView, indexPath, row: (indexPath.row - (Int(itemsNumber) - firstWeekday)) )
                }
            } else {
                if firstday >= firstWeekday {
                    if firstday == firstWeekday {
                        return createCalendarCell(collectionView, indexPath, row: indexPath.row)
                    } else {
                        if indexPath.row < firstday - firstWeekday {
                            return createBlankCell(collectionView, indexPath)
                        } else {
                            return createCalendarCell(collectionView, indexPath, row: indexPath.row - (firstday - firstWeekday) )
                        }
                    }
                } else {
                    if indexPath.row < firstday + (Int(itemsNumber) - firstWeekday) {
                        return createBlankCell(collectionView, indexPath)
                    } else {
                        return createCalendarCell(collectionView, indexPath, row: indexPath.row - (firstday + Int(itemsNumber) - firstWeekday) )
                    }
                }
            }
        }
        
    }
    
    /// 创建空白 Cell
    fileprivate func createBlankCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: normalCell, for: indexPath)
        
        return cell
    }
    
    /// 创建 CalendarCell
    fileprivate func createCalendarCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, row: Int) -> CalendarCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! CalendarCell
        
        /* 给按钮注册、放弃 第一响应者
         防止通过"弹出菜单"设置按钮背景状态时,
         同时滚动造成的按钮消失的问题.
         */
        cell.planButton?.becomeFirstResponder()
        cell.planButton?.resignFirstResponder()
        
        cell.planButton?.buttonTapHandler = { (operatingButton) in
            // 设置按钮状态颜色
            self.statusCache["\((operatingButton.id)!)"] = operatingButton.bgStatus.rawValue
            
            /* 判断点击的日期是否是未来日期
             未来日期不可选择, 不会保存, 同时震动提示
             */
            self.opinionDate(operatingButton, isLongPress: false)
        }
        
        // 按钮长按手势事件
        cell.planButton?.longPressHandler = { (operatingButton) in
            self.opinionDate(operatingButton, isLongPress: true)
        }
        
        // 设置按钮日期文字
        cell.planButton?.setTitle("\(row + 1)", for: .normal)
        
        /* 设置按钮 ID */
        var sectionStr = ""
        
        if (indexPath.section + 1).description.characters.count == 1 {
            sectionStr = "0\(indexPath.section + 1)"
        } else {
            sectionStr = "\(indexPath.section + 1)"
        }
        
        var rowStr = ""
        if (row + 1).description.characters.count == 1 {
            rowStr = "0\(row + 1)"
        } else {
            rowStr = "\(row + 1)"
        }

        cell.planButton?.id = "\((self.title)!)#\(thisYear)\(sectionStr)\(rowStr)"
        
        if "\(sectionStr)\(rowStr)" == self.todayStr {
            cell.todayIndicator.isHidden = false
        } else {
            cell.todayIndicator.isHidden = true
        }
        
        /* ---------- */
        // 设置按钮状态颜色
        if statusCache["\((cell.planButton?.id)!)"] == nil {
            cell.planButton?.bgStatus = .Base
            statusCache["\((cell.planButton?.id)!)"] = "Base"
        } else {
            let statusStr = statusCache["\((cell.planButton?.id)!)"] as! String
            cell.planButton?.bgStatus = StatusType(rawValue: statusStr)!
        }
        /* ---------- */
        // 备注相关设置
        if dataStrCache["\((cell.planButton?.id)!)"] == nil {
            dataStrCache["\((cell.planButton?.id)!)"] = ""
        } else {
            cell.planButton?.dataStr = (dataStrCache["\((cell.planButton?.id)!)"] as! String)
        }
        
        // 备注小圆点指示器判断
        if cell.planButton?.dataStr != nil {
            opinionIndicator(button: (cell.planButton)!, text: (cell.planButton?.dataStr)!)
        }
        /* ---------- */
        
        DispatchQueue.main.async {
            self.setupInterface(btn: cell.planButton!)
        }
                
        return cell
    }
    
    // headerView 尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 11 {
            return CGSize(width: UIScreen.main.bounds.width, height: footerHeight)
        } else {
            return .zero
        }
    }
    
    // 自定义 headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! CollectionReusableHeaderView
            (reusableView as! CollectionReusableHeaderView).title.text = months[indexPath.section]
        }
        
        if kind == UICollectionElementKindSectionFooter, indexPath.section == 11 {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerIdentifier, for: indexPath) as! CollectionReusableHeaderView
            (reusableView as! CollectionReusableHeaderView).title.text = "Footer"
        }
        
        return reusableView!
    }
    
}

// MARK:- 日期相关
extension CalendarViewController: CAAnimationDelegate {
    /// 日期判断
    /// - 判断点击的日期是否是未来日期
    /// - 未来日期不可选择，不会保存，同时震动提示。
    /// - parameter operatingButton: 点击的按钮
    /// - parameter isLongPress: 是否为长按操作
    fileprivate func opinionDate(_ operatingButton: ColorfulButton, isLongPress: Bool) {
        let nowDateStr = DateTool.shared.getCompactDate()
        // ID 的范围
        let fullRnage = Range(uncheckedBounds: (lower: (operatingButton.id)!.startIndex, upper: (operatingButton.id)!.endIndex))
        
        // 倒叙查找到标识符的范围
        let identifierRange = (operatingButton.id)!.range(of: "#", options: .backwards, range: fullRnage, locale: nil)
        
        let index = (operatingButton.id)!.index(identifierRange!.lowerBound, offsetBy: 1)
        
        let title = (operatingButton.id)!.substring(from: index)
        
        if Int(title)! <= Int(nowDateStr)! {
            if isLongPress {
                 operatingButton.menu.setMenuVisible(true, animated: true)
            }
            
            let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((self.title)!)#\(self.thisYear)")
            if let dataArray = dataArray, dataArray.count != 0 {
                let statusDict = dataArray[1] as! [String: Any]
                if statusDict["\((operatingButton.id)!)"] == nil {
                    _ = SQLite.shared.insert(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                } else {
                    _ = SQLite.shared.update(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                }
            } else {
                _ = SQLite.shared.insert(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
            }
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            shake(button: (weekTitleView.selectedWeek)!)
            operatingButton.bgStatus = .Base
            self.statusCache["\((operatingButton.id)!)"] = "Base"
            operatingButton.menu.setMenuVisible(false, animated: true)
        }
    }
    
    /// "左右摇晃"动画
    fileprivate func shake(button: UIButton) {
        let shakeAnimation = CAKeyframeAnimation()
        shakeAnimation.keyPath = "transform.translation.x"
        // 偏移量
        let offset = 2.5
        // 过程
        shakeAnimation.values = [-offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0, -offset, 0, offset, 0]
        // 动画时间
        shakeAnimation.duration = 0.3
        // 执行次数
        shakeAnimation.repeatCount = 1
        // 切出此界面再回来动画不会停止
        shakeAnimation.isRemovedOnCompletion = true
        shakeAnimation.delegate = self
        
        button.layer.add(shakeAnimation, forKey: "shake")
    }
    
    /// 滚动到现在的月份
    fileprivate func scrollToThisMonth(animated: Bool = false) {
        // 今天是几月份
        let month = Calendar.current.component(.month, from: Date())
        
        var indexPath: IndexPath?

        if month == 1 {
            // 一月份时, 不进行偏移
            indexPath = IndexPath(row: 0, section: 0)
        } else if month == 12 {
            // 12 月时, 偏移到上一个月初
            indexPath = IndexPath(row: 0, section: month - 1)
        } else {
            // 上个月有几天
            let previousDayOfMonth = dayOfMonth[month - 2]
            // 偏移到上个月末
            indexPath = IndexPath(row: previousDayOfMonth - 1, section: month - 2)
        }
        
        collectionView?.scrollToItem(at: indexPath!, at: .top, animated: animated)
    }
    
}

// MARK: - 备注界面相关
extension CalendarViewController {
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
                
                self.title = self.naviTitle
            }
            
            remarksVC.pinTapHandler = { (_, text) in
                self.dismiss(animated: true, completion: nil)
                
                UIView.animate(withDuration: 0.3, animations: { 
                    self.effectView?.alpha = 0
                }, completion: { (_) in
                    self.navigationController?.navigationBar.isHidden = false
                })
                
                // 添加到缓存
                self.dataStrCache["\((self.chooseBtn?.id)!)"] = text!
                
                self.chooseBtn?.dataStr = text!
                
                let dataArray = SQLite.shared.query(inTable: regularDataBase, id: "\((self.title)!)#\(self.thisYear)")
                if let dataArray = dataArray, dataArray.count != 0 {
                    let remarksDict = dataArray[2] as! [String: Any]
                    if remarksDict["\((self.chooseBtn?.id)!)"] == nil {
                        _ = SQLite.shared.insert(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                    } else {
                        _ = SQLite.shared.update(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                    }
                } else {
                    _ = SQLite.shared.insert(id: "\((self.title)!)#\(self.thisYear)", statusDict: self.statusCache, remarksDict: self.dataStrCache, inTable: regularDataBase)
                }
                
                if let text = text, let chooseBtn = self.chooseBtn {
                    self.opinionIndicator(button: chooseBtn, text: text)
                }
                self.title = self.naviTitle
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
    
}

// MARK:- 通知相关
extension CalendarViewController {
    
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTodayIndicator), name: timeChangeNotification, object: nil)
    }
    
    // 更新"今天指示器"
    @objc fileprivate func updateTodayIndicator() {
        // 今天的日期 ID
        let date = DateTool.shared.getCompactDate(dateFormat: "MMdd")
        self.todayStr = "\(date)"
                
        collectionView?.reloadData()
    }

}

// MARK:- 数据加载
extension CalendarViewController {
    
}

// MARK:- 蒙版
extension CalendarViewController {
    /// 点击菜单备注弹出窗口背景添加蒙版
    fileprivate func setupBlur() {
        let effect = UIBlurEffect(style: .dark)
        effectView = UIVisualEffectView(effect: effect)
        effectView?.frame = UIScreen.main.bounds
        effectView?.alpha = 0
        view.addSubview(effectView!)
    }
    
}

// MARK:- 自定义 collectionView 头部控件
class CollectionReusableHeaderView: UICollectionReusableView {
    // MARK: >>> 头部标题
    let title = UILabel()

    // MARK: >>> 自定义构造方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title.frame = self.bounds
        title.textAlignment = .center
        title.layer.masksToBounds = true
        title.isOpaque = true
        title.backgroundColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 20)
        
        title.textColor = appColor
        
        addSubview(title)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
