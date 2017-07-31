//
//  CommonFilterViewModel.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift

class CommonFilterViewModel: BaseViewModel , CommonFilterTools {

    /// 筛选条件集合
    var commonFilters = [CommonFilterConfigSectionModel]()
    
    init(filterFileName : String) {
        super.init()
        commonFilters = plistConfig(filterFileName)
    }
}

protocol CommonFilterTools
{
    func plistConfig(_ fileName : String) -> [CommonFilterConfigSectionModel]
}

extension CommonFilterTools
{
    // MARK: - 获取plist筛选
    func plistConfig(_ fileName : String) -> [CommonFilterConfigSectionModel]
    {
        guard let filterUrl = Bundle.main.path(forResource: fileName, ofType:"plist") else { return [CommonFilterConfigSectionModel]()}
        
        guard let configs = NSArray(contentsOfFile:filterUrl) else { return [CommonFilterConfigSectionModel]() }
        
        guard let filters = configs as? [NSDictionary] else { return [CommonFilterConfigSectionModel]() }
        
        return filters.map { CommonFilterConfigSectionModel(dic: $0) }
        
    }
}
