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

class CalendarViewController: UIViewController {
    // MARK:- 属性
    
    fileprivate let layout = UICollectionViewFlowLayout()
    fileprivate var collectionView: UICollectionView?
    
    /// **collectionView** 每个 **cell** 上下左右的间距
    fileprivate let cellItemSpace: CGFloat = 3
    /// 每行 **cell** 个数
    fileprivate let itemsNumber: CGFloat = 7
    
    let weekTitleView = WeekView()
    
    var chooseBtn: ColorfulButton?
    
    var effectView: UIVisualEffectView?
    
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
    
    // MARK:- 系统函数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(CollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
//        collectionView?.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: collectionCellIdentifier)
        collectionView?.register(CalendarCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
//        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
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
        
        let frame = CGRect(x: 0, y: weekTitleView.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - weekTitleView.bounds.height)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        collectionView?.collectionViewLayout = layout
        
        // 每个cell的尺寸
        let oneItemSize: CGFloat = (collectionView?.bounds.width)! / itemsNumber - cellItemSpace
        let itemSize = CGSize(width: oneItemSize, height: oneItemSize)
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = cellItemSpace // 左右间隔
        layout.minimumLineSpacing = cellItemSpace // 上下间隔
        // 页眉的尺寸
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        view.addSubview(collectionView!)
    }
    
}

// MARK:- collectionView 数据源、代理方法
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! CalendarCell
        
        cell.planButton?.id = "\(year)\(indexPath.section)\(indexPath.row)"
        
        EventManager.shared.accessButton(button: cell.planButton!)
        
        setupInterface(btn: cell.planButton!)
        
        return cell
    }
    
    // headerView 尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
    
    // 自定义 headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! CollectionReusableHeaderView
            (reusableView as! CollectionReusableHeaderView).title.text = "text"
        }
        
        return reusableView!
    }
    
}

extension CalendarViewController {
    fileprivate func setupInterface(btn: ColorfulButton) {
        let remarksVC = RemarksController()
        btn.remarksTapHandler = { (button) in
            self.setupBlur()
            self.chooseBtn = button
            
            if button.dataStr != nil {
                remarksVC.textView.text = button.dataStr!
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.effectView?.alpha = 1.0
                
                remarksVC.modalPresentationStyle = .custom
                self.present(remarksVC, animated: true, completion: nil)
            })
        }
        
        // 取消备注后隐藏蒙版
        remarksVC.cancelTapHandler = { (vc) in
            UIView.animate(withDuration: 0.3) {
                self.effectView?.alpha = 0
            }
        }
        
        remarksVC.pinTapHandler = { (vc, text) in
            UIView.animate(withDuration: 0.3) {
                self.effectView?.alpha = 0
            }
            
            self.chooseBtn?.dataStr = text!
            
            _ = SQLite.shared.update(id: (self.chooseBtn?.id)!, status: "\((self.chooseBtn?.bgStatus)!)", remark: text!, inTable: "t_buttons")
            
            if let text = text, let chooseBtn = self.chooseBtn {
                self.opinionIndicator(button: chooseBtn, text: text)
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
        let titleX: CGFloat = 10
        title.frame = CGRect(x: titleX, y: 0, width: bounds.width - titleX, height: 40)
        addSubview(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
