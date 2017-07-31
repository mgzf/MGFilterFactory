//
//  FilterDelegates.swift
//  MogoPartner
//
//  Created by Harly on 2017/2/21.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit

/// FilterHeader必须要用这个哦
protocol FilterHeaderDelegate : NSObjectProtocol {
    
    func viewForContent() -> UIView?
    
    func viewForFilter(_ filterModel: CommonFilterConfigSectionModel, atIndex: Int) -> (view :UIView , contentDelegate : FilterContentInstaller)?
    
    func edgetForFilter(_ filterModel : CommonFilterConfigSectionModel , atIndex : Int) -> UIEdgeInsets
    
    func onFilterClosed(_ para : [String: Any]?)
    
    func offsetHeight(_ filterId : String) -> CGFloat?
    
}

extension FilterHeaderDelegate {
    public func offsetHeight(_ filterId : String) -> CGFloat? {
        return 0
    }
}

protocol FilterHeaderInstaller : AnyObject {
    
    
//    var communityManageVM : FindLandlordCommunitiesViewModel? { get set }
    
    /// 根据model创建相应headerview
    ///
    /// - Parameter filterModel: model
    /// - Returns: view , delegate
    func installFilterForYouWithModel(_ filterModel : CommonFilterConfigSectionModel ,preParas : [String: Any]?) -> (view :UIView , contentDelegate : FilterContentInstaller)?
}

protocol FilterContentInstaller {
    
    var containsPrePara : Bool { get set }
    
    var containedPara : [String: Any] { get set }
    
    /// 配置初始参数
    ///
    /// - Parameter preParas: paras
    /// - Returns: 是否含有参数
    func configPrePara(_ preParas: [String: Any]?) -> Bool
    
    /// 完成筛选后回调
    var filterCompletion : (([String: Any] , String? , Bool)->Void)? { get set }
}

extension FilterHeaderInstaller where Self : UIViewController
{
    func installFilterForYouWithModel(_ filterModel : CommonFilterConfigSectionModel ,preParas : [String: Any]?) -> (view :UIView , contentDelegate : FilterContentInstaller)?
    {
        guard let type = filterModel.sectionType else { return nil }
        switch type{
            
        case .multipleChoice , .singleChoice :
            
            guard let internalArray = filterModel.internalArray else { return nil }
            
            let table = FilterContentTableView()
            table.setupWithConfig(internalArray)
            filterModel.isValid = table.configPrePara(preParas)
            
            if !table.selectedTitle.isEmpty
            {
                filterModel.sectionName = table.selectedTitle
            }
            
            return (table , table)
            
        case .filterPicker:
            
            let filterController = CommonFilterController(filterPlist: filterModel.otherString, preParas : preParas , withConfiguration: { [weak self](config) in
                guard let `self` = self else { return }
                //                if config.sectionName.containsString("小区")
                //                {
                //                    config.internalArray = self.communityManageVM.communityArray
                //                }
                
                }, onCompletion: {[weak self] (para , highlight) in
                    guard let `self` = self else { return }
                    //                    //处理奇怪的日期选择
                    //                    let newPara = self.repairDateFromParaDic(para)
                    //
                    //                    if hasFilter
                    //                    {
                    //                        self.highliteFilter()
                    //                    }
                    //                    else
                    //                    {
                    //                        self.delightFilter()
                    //                    }
                    //                    self.repairInitPara = nil
                    //                    selectedConifg.filterPara = newPara
                    //                    self.refreshCurrentContent(newPara)
                })
            
            
            
//            communityManageVM = FindLandlordCommunitiesViewModel()
//            communityManageVM!.request({ (success) in
//                filterController.reConfigSections({ [weak self](config) in
//                    
//                    guard let `self` = self else { return }
//                    
//                    if config.sectionName.contains("小区")
//                    {
//                        config.internalArray = self.communityManageVM!.communityArray
//                    }
//                    })
//                
//            })
            
            filterController.needHideTitle = true
            
            filterModel.isValid = filterController.containsPrePara
            
            return (filterController.view , filterController)
        default:
            return nil
        }
    }
}

