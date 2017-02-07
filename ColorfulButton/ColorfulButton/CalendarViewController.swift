//
//  CalendarViewController.swift
//  ColorfulButton
//
//  Created by zhi zhou on 2017/2/4.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit

private let collectionCellIdentifier = "collectionCell"
private let headerIdentifier = "headerCell"
private let normalCell = "normalCell"

class CalendarViewController: UIViewController {
    // MARK:- 属性
    
    fileprivate let layout = UICollectionViewFlowLayout()
    fileprivate var collectionView: UICollectionView?
    /// 头部高度
    fileprivate let headerHeight: CGFloat = 40
    
    /// **collectionView** 每个 **cell** 上下左右的间距
    fileprivate let cellItemSpace: CGFloat = 3
    /// 每行 **cell** 个数
    fileprivate let itemsNumber: CGFloat = 7
    
    let weekTitleView = WeekView()
    
    var chooseBtn: ColorfulButton?
    
    var effectView: UIVisualEffectView?
    /// 月份标识数组
    fileprivate var months = [String]()
    
    let naviTitle = "Detail"
    
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
        setupInterface()
        self.title = naviTitle
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        collectionView?.register(CalendarCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: normalCell)
        
        weekTitleView.frame = CGRect(x: 0, y: 64, width: weekTitleView.bounds.width, height: weekTitleView.bounds.height)
        view.addSubview(weekTitleView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK:- 界面设置
    fileprivate func setupInterface() {
        let naviBar = navigationController?.navigationBar
        let naviBarBottomLine = naviBar?.subviews.first?.subviews.first
        
        if (naviBarBottomLine?.isKind(of: UIImageView.self))! {
            // 隐藏导航栏底部的黑色细线
            naviBarBottomLine?.isHidden = true
        }
        
        
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
        collectionView?.collectionViewLayout = layout
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.contentInset = UIEdgeInsets(top: weekTitleView.bounds.height, left: 0, bottom: 0, right: 0)
        
        
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
        let firstday = firstdayOfWeek[section]
        if firstday == 0 {
            return dayOfMonth[section]
        } else {
            return dayOfMonth[section] + (firstday)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let firstday = firstdayOfWeek[indexPath.section]
        
        if firstday != 0, indexPath.row < firstday {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: normalCell, for: indexPath)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! CalendarCell
        
            cell.planButton?.buttonTapHandler = { (operatingButton) in
                if operatingButton.dataStr != nil || operatingButton.dataStr != "" {
                    _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "\(operatingButton.dataStr!)", inTable: tableName)
                } else {
                    _ = SQLite.shared.update(id: operatingButton.id!, status: "\(operatingButton.bgStatus)", remark: "", inTable: tableName)
                }
                
                self.update(operatingButton, isChangeStatus: true)
            }
            
            cell.model = self.models?[indexPath.section][indexPath.row - firstday]
            
            DispatchQueue.main.async {
                self.setupInterface(btn: cell.planButton!)
            }
            
            return cell
        }
    }
        
    // headerView 尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
    }
    
    // 自定义 headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! CollectionReusableHeaderView
            (reusableView as! CollectionReusableHeaderView).title.text = months[indexPath.section]
        }
        
        return reusableView!
    }
    
}

// MARK: - 备注界面相关
extension CalendarViewController {
    fileprivate func setupInterface(btn: ColorfulButton) {
        btn.remarksTapHandler = { (button) in
            self.setupBlur()
            self.chooseBtn = button
            let remarksVC = RemarksController()
            
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
                self.effectView?.alpha = 1.0
            })

            // 取消备注后隐藏蒙版
            remarksVC.cancelTapHandler = { (_) in
                UIView.animate(withDuration: 0.3) {
                    self.effectView?.alpha = 0
                }
                self.title = self.naviTitle
            }
            
            remarksVC.pinTapHandler = { (_, text) in
                UIView.animate(withDuration: 0.3) {
                    self.effectView?.alpha = 0
                }
                
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
        for day in days {
            var monthStatus = [StatusModel]()
            for i in 1...day {
                var dict = [String: Any]()
                let id = "\(year)\(monthNum)\(i)"
                dict["id"] = id

                let dataArray = SQLite.shared.query(inTable: tableName, id: id)
                if dataArray?.count != 0 {
                    let savedID = dataArray?[0] as! String
                    let savedStatus = dataArray?[1] as! String
                    let savedRemark = dataArray?[2] as! String
                    
                    if savedID == id {
                        dict["status"] = savedStatus
                        dict["dataStr"] = savedRemark
                        dict["dateStr"] = "\(i)"
                    }
                } else {
                    dict["status"] = "Base"
                    dict["dataStr"] = ""
                    dict["dateStr"] = "\(i)"
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
        
        title.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: self.bounds.height))
        title.textAlignment = .center
        title.layer.masksToBounds = true
        title.isOpaque = true
        title.backgroundColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 18)
        
        title.textColor = UIColor(red: 88/255.0, green: 170/255.0, blue: 23/255.0, alpha: 1.0)
        
        addSubview(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
