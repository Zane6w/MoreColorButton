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
    /// 标题
    let identifyLabel = UILabel()
    
    var collectionView: UICollectionView?
    
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    /// 一行有几个 Cell
    fileprivate let numberOfOneRow = 7
    /// **collectionView** 每个 **cell** 上下左右的间距
    fileprivate let itemSpace: CGFloat = 3
    
    var cellHeight: CGFloat = 0
    
    /// 主页数据模型
    var regularModels: [[StatusModel]]? {
        didSet {
            
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
        setupIdentifyLabel()
        setupCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- 初始化属性
    fileprivate func setupIdentifyLabel() {
        identifyLabel.frame = .zero
        identifyLabel.text = "测试"
        identifyLabel.font = UIFont.systemFont(ofSize: 18)
        identifyLabel.sizeToFit()
        
        self.contentView.addSubview(identifyLabel)
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
        
        return cell
    }
    
}







































