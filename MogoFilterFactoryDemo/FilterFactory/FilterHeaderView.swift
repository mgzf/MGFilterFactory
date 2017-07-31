//
//  FilterHeaderView.swift
//  MogoPartner
//
//  Created by Harly on 2017/2/20.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit
import SnapKit

struct ReuseableFilterContent
{
    var sectionId : String = ""
    var contentView : (view :UIView , contentDelegate : FilterContentInstaller)?
    var edget : UIEdgeInsets = UIEdgeInsets.zero
    var filterParameter : [String: Any]?
}

class FilterHeaderView: UIView , CommonFilterTools
{
    // MARK: - UI related
    var headerCollectionView : UICollectionView!
    
    weak var filterDelegate : FilterHeaderDelegate?
    
    var contentBodyView : UIView?
    
    // MARK: - Filter related
    fileprivate var runningSectionId = ""
    
    var filterTitleModels = [CommonFilterConfigSectionModel]()
    
    var preRunningPara : [String: Any]?
    
    // MARK: - initilizer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    fileprivate func initViews()
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        headerCollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        headerCollectionView.register(UINib(nibName: "CommonFilterHeaderCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CommonFilterHeaderCell")
        headerCollectionView.backgroundColor = UIColor.white
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        addSubview(headerCollectionView)
        
        headerCollectionView.snp_makeConstraints {[weak self] (make) in
            guard let `self` = self else { return }
            make.left.right.top.bottom.equalTo(self)
        }
        
        let line = UILabel(frame: CGRect.zero)
        line.text = ""
        line.backgroundColor = kColor_partLine
        addSubview(line)
        
        line.snp_makeConstraints {[weak self] (make) in
            guard let `self` = self else { return }
            make.right.left.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - public installation
    func installView(_ configFile : String , prePara : [String: Any]? = nil)
    {
        filterTitleModels = plistConfig(configFile)
        headerCollectionView.reloadData()
        
        // Config content
        guard let viewDelegate = filterDelegate else { return }
        
        for filter in filterTitleModels
        {
            let contentView = viewDelegate.viewForFilter(filter, atIndex: filterTitleModels.index(of: filter)!)
            
            guard var realContentView = contentView else { continue }
            
            realContentView.contentDelegate.filterCompletion = {[weak self](para , title , highlight) in
                guard let `self` = self else { return }
                
                if var cachedFilter = self.reuseFilterCache[filter.sectionId]
                {
                    cachedFilter.filterParameter = para
                    
                    self.reuseFilterCache[filter.sectionId] = cachedFilter
                    
                    // TODO: 谁改谁是猪
                    if highlight && para.count > 0
                    {
                        filter.isValid = true
                    }
                    else
                    {
                        filter.isValid = false
                    }
                }
                
                if let realTitle = title
                {
                    filter.sectionName = realTitle
                }
                
                self.headerCollectionView.reloadData()
                
                self.handleFilter()
                
                self.hideContentFilter()
            }
            
            reuseFilterCache[filter.sectionId] = ReuseableFilterContent(sectionId: filter.sectionId, contentView: realContentView, edget: viewDelegate.edgetForFilter(filter, atIndex: filterTitleModels.index(of: filter)!), filterParameter: realContentView.contentDelegate.containedPara)
        }
        
        contentBodyView = viewDelegate.viewForContent()
        
        preRunningPara = prePara
        
        headerCollectionView.reloadData()
        
    }
    
    // MARK: - Content related
    
    fileprivate func varifyFilterWhenTapBlank()
    {
        //        let runningFilters = filterTitleModels.filter { $0.sectionId == runningSectionId}
        //
        //        guard let firstFilter = runningFilters.first else
        //        {
        //            return
        //        }
        //
        //        guard let cachedFilter = reuseFilterCache[firstFilter.sectionId] else
        //        {
        //            firstFilter.isRunning = false
        //            headerCollectionView.reloadData()
        //            return
        //        }
        //
        //        guard let filterPara = cachedFilter.filterParameter else
        //        {
        //            firstFilter.isRunning = false
        //            headerCollectionView.reloadData()
        //            return
        //        }
        //
        //        firstFilter.isRunning = filterPara.count > 0
        
        headerCollectionView.reloadData()
        
    }
    
    fileprivate func handleFilter()
    {
        var finalFilterPara = [String: Any]()
        
        for filter in reuseFilterCache.values
        {
            if let para = filter.filterParameter
            {
                para.forEach { finalFilterPara[$0] = $1 }
            }
        }
        
        guard let viewDelegate = filterDelegate else { return }
        
        preRunningPara = finalFilterPara
        
        viewDelegate.onFilterClosed(finalFilterPara)
    }
    
    fileprivate var reuseFilterCache = [String : ReuseableFilterContent]()
    
    func showContentFilter(_ filterId : String)
    {
        runningSectionId = filterId
        
        guard let filterContent = reuseFilterCache[filterId] else { return }
        
        guard let filterContentView = contentBodyView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            filterContentView.alpha = 1
        }) 
        
        filterContentView.subviews.forEach { $0.removeFromSuperview() }
        
        let bgView = UIView(frame: filterContentView.bounds)
        bgView.backgroundColor = UIColor.clear
        
        bgView.tapGesture({[weak self] in
            guard let `self` = self else { return }
            self.varifyFilterWhenTapBlank()
            self.hideContentFilter()
            })
        
        filterContentView.addSubview(bgView)
        
        guard let contentPair = filterContent.contentView else { return }
        
        filterContentView.addSubview(contentPair.view)
        
        contentPair.contentDelegate.configPrePara(preRunningPara)
        
        guard let viewDelegate = filterDelegate else {
            contentPair.view.snp_makeConstraints {(make) in
                make.left.equalTo(filterContentView).offset(filterContent.edget.left)
                make.right.equalTo(filterContentView).offset(filterContent.edget.right)
                make.top.equalTo(filterContentView).offset(filterContent.edget.top)
                make.bottom.equalTo(filterContentView).offset(filterContent.edget.bottom)
            }
            return }
        let offset:CGFloat = viewDelegate.offsetHeight(filterId) ?? 0
        contentPair.view.snp_makeConstraints {(make) in
            make.left.equalTo(filterContentView).offset(filterContent.edget.left)
            make.right.equalTo(filterContentView).offset(filterContent.edget.right)
            make.top.equalTo(filterContentView).offset(filterContent.edget.top)
            make.bottom.equalTo(filterContentView).offset(filterContent.edget.bottom - offset)
        }
        
    }
    
    func hideContentFilter()
    {
        guard let filterContentView = contentBodyView else { return }
        
        filterTitleModels.forEach { $0.isRunning = false }
        
        headerCollectionView.reloadData()
        
        runningSectionId = ""
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: UIViewAnimationOptions(), animations: {
            filterContentView.alpha = 0
        }) { (success) in
            filterContentView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
}

extension FilterHeaderView : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterTitleModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard filterTitleModels.count != 0 else { return CGSize.zero }
        let width = frame.width / CGFloat(filterTitleModels.count)
        let height = frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommonFilterHeaderCell", for: indexPath) as! CommonFilterHeaderCell
        
        let model = filterTitleModels[indexPath.row]
        cell.filter = model
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = filterTitleModels[indexPath.row]
        
        //        if model.isRunning
        //        {
        //            model.isRunning = false
        //
        //            collectionView.reloadData()
        //
        //            hideContentFilter()
        //
        //            return
        //        }
        
        guard !model.isRunning else
        {
            model.isRunning = false
            varifyFilterWhenTapBlank()
            hideContentFilter()
            return
        }
        
        filterTitleModels.forEach { $0.isRunning = false }
        
        model.isRunning = true
        
        showContentFilter(model.sectionId)
        
        collectionView.reloadData()
        
        //        if !model.isRunning
        //        {
        //            hideContentFilter()
        //        }
        //        else
        //        {
        //            showContentFilter(model.sectionId)
        //        }
    }
}
