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
    
    /// 语言判断
    var isHanLanguage: Bool {
        // 判断系统当前语言
        let languages = Locale.preferredLanguages
        let currentLanguage = languages[0]
        // 判断是否是中文, 根据语言设置字体样式
        if currentLanguage.hasPrefix("zh") {
            return true
        } else {
            return false
        }
    }
    
    /// 年份（可根据年份前缀来赋值按钮 ID，可用来查询旧数据）
    let year = 2017
    
    let dayOfMonth = DateTool.shared.getDayOfMonth()
    let firstdayOfWeek = DateTool.shared.getFirstMonthDayOfWeek()
    
    fileprivate var models: [[StatusModel]]?
    
    // MARK:- 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        weekTitleView.frame = CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: UIScreen.main.bounds.width, height: 30)

        setupInterface()
        
        naviTitle = self.title!
        
        weekTitleView.firstWorkday = self.firstWeekday
        
        view.addSubview(weekTitleView)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        collectionView?.register(CalendarCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: normalCell)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
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
//        collectionView?.collectionViewLayout = layout
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
        
        
        if isHanLanguage {
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
        
        cell.planButton?.buttonTapHandler = { (operatingButton) in
            /* 判断点击的日期是否是未来日期
             未来日期不可选择, 不会保存, 同时震动提示
             */
            self.opinionDate(operatingButton)
        }

        cell.model = self.models?[indexPath.section][row]
        
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

// MARK:- 日期判断
extension CalendarViewController {
    /// 日期判断
    /// - 判断点击的日期是否是未来日期
    /// - 未来日期不可选择，不会保存，同时震动提示。
    /// - parameter operatingButton: 点击的按钮
    fileprivate func opinionDate(_ operatingButton: ColorfulButton) {
        let nowDateStr = DateTool.shared.getCompactDate()
        
        if Int((operatingButton.id)!)! <= Int(nowDateStr)! {
            if operatingButton.dataStr != nil || operatingButton.dataStr != "" {
                _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "\(operatingButton.dataStr!)", inTable: tableName)
            } else {
                _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "", inTable: tableName)
            }
            
            self.update(operatingButton, isChangeStatus: true)
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            operatingButton.bgStatus = .Base
        }
    }
    
}

// MARK: - 备注界面相关
extension CalendarViewController {
    fileprivate func setupInterface(btn: ColorfulButton) {
        btn.remarksTapHandler = { (button) in
            self.setupBlur()
            self.chooseBtn = button
            let remarksVC = RemarksController()
            
            // 随时改变标题显示
            let dateTuples = DateTool.shared.filterMonthAndDay(dateStr: (button.id)!, yearStr: "\(self.year)")
            let monthStr = dateTuples.month
            let dayStr = dateTuples.day
            
            if self.isHanLanguage {
                self.title = "\(monthStr)月\(dayStr)日"
            } else {
                let englishMonths = ["Jan.", "Feb.", "Mar.", "Apr.", "May.", "Jun.", "Jul.", "Aug.", "Sept.", "Oct.", "Nov.", "Dec."]
                
                self.title = "\(englishMonths[Int(monthStr)! - 1]) \(dayStr)"
            }
            
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
                UIView.animate(withDuration: 0.3, animations: { 
                    self.effectView?.alpha = 0
                }, completion: { (_) in
                    self.navigationController?.navigationBar.isHidden = false
                })

                self.chooseBtn?.dataStr = text!
                
                _ = SQLite.shared.update(id: (self.chooseBtn?.id)!, status: "\((self.chooseBtn?.bgStatus)!)", remark: text!, inTable: "t_buttons")
                
                self.update(self.chooseBtn!, isChangeStatus: false)
                
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
            if isHanLanguage {
                button.remarksTitle = "编辑备注"
            } else {
                button.remarksTitle = "Edit Note"
            }
            
            button.reloadMenu()
        } else {
            
            // 判断系统当前语言
            if isHanLanguage {
                button.remarksTitle = "添加备注"
            } else {
                button.remarksTitle = "Add Note"
            }
            
            button.indicator.isHidden = true
            button.reloadMenu()
        }
    }
    
}

// MARK:- 数据加载
extension CalendarViewController {
    /// 添加新数据
    fileprivate func loadData() {
        self.models = [[StatusModel]]()
        let days = DateTool.shared.getDayOfMonth(year: "\(year)")
        var monthNum = 1
        var id = ""
        for day in days {
            var monthStatus = [StatusModel]()
            for i in 1...day {
                var dict = [String: Any]()

                if monthNum.description.characters.count == 1 {
                    if i.description.characters.count == 1 {
                        id = "\(year)0\(monthNum)0\(i)"
                    } else {
                        id = "\(year)0\(monthNum)\(i)"
                    }
                } else {
                    if i.description.characters.count == 1 {
                        id = "\(year)\(monthNum)0\(i)"
                    } else {
                        id = "\(year)\(monthNum)\(i)"
                    }
                }
                
                dict["id"] = id

                let dataArray = SQLite.shared.query(inTable: tableName, id: id)
                if dataArray?.count != 0 {
                    let savedID = dataArray?[0] as! String
                    let savedStatus = dataArray?[1] as! String
                    let savedRemark = dataArray?[2] as! String
                    
                    if savedID == id {
                        dict["status"] = savedStatus
                        dict["dataStr"] = savedRemark
                        dict["dayStr"] = "\(i)"
                    }
                } else {
                    dict["status"] = "Base"
                    dict["dataStr"] = ""
                    dict["dayStr"] = "\(i)"
                    _ = SQLite.shared.insert(id: id, status: "Base", remark: "", inTable: tableName)
                }
                
                let status = StatusModel(dict: dict)
                monthStatus.append(status)
            }
            monthNum += 1
            self.models?.append(monthStatus)
        }
    }
    
    /// 更新数据
    /// - parameter operatingButton: 正在操作的按钮
    /// - parameter isChangeStatus: 是否更改按钮状态
    fileprivate func update(_ operatingButton: ColorfulButton, isChangeStatus: Bool) {
        let index = self.models?.index(where: { (model) -> Bool in
            var isSuccess: Bool = false
            for single in model {
                if single.id! == operatingButton.id! {
                    isSuccess = true
                }
            }
            return isSuccess
        })
        
        let singleModel = self.models?[index!]
        
        // 是否需要修改按钮状态
        if isChangeStatus {
            for model in singleModel! {
                if model.id! == operatingButton.id! {
                    model.status = "\(operatingButton.bgStatus)"
                    model.dataStr = operatingButton.dataStr!
                }
            }
        } else {
            for model in singleModel! {
                if model.id! == operatingButton.id! {
                    model.dataStr = operatingButton.dataStr!
                }
            }
        }
    }
    
}

// MARK:- 手势相关
extension CalendarViewController: UIGestureRecognizerDelegate {
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
