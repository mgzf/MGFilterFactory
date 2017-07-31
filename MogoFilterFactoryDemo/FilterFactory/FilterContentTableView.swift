//
//  FilterContentTableView.swift
//  MogoPartner
//
//  Created by Harly on 2017/2/21.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit
import SnapKit

class FilterContentTableView: UIView {
    
    var containedPara = [String: Any]()
    
    var containsPrePara : Bool = false
    
    var selectedTitle = ""
    
    var filterContentModels = [ConfigModel]()
    
    var filterCompletion : (([String: Any] , String? , Bool)->Void)?
    
    var tableView : UITableView!
    
    func setupWithConfig(_ configs : [ConfigModel])
    {
        filterContentModels = configs
        
        installTableView()
    }
    
    func installTableView()
    {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommonConfigCell", bundle: Bundle.main), forCellReuseIdentifier: "CommonConfigCell")
        addSubview(tableView)
        
        tableView.snp_makeConstraints {[weak self] (make) in
            guard let `self` = self else { return }
            make.left.right.top.bottom.equalTo(self)
        }
        tableView.separatorColor = kColor_partLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
}

extension FilterContentTableView : UITableViewDelegate , UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterContentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonConfigCell") as! CommonConfigCell
        
        let model = filterContentModels[indexPath.row]
        
        cell.model = model
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterContentModels.forEach { $0.isSelect = false }
        let model = filterContentModels[indexPath.row]
        model.isSelect = true
        
        tableView.reloadData()
        
        guard let realCompletion = filterCompletion else { return }
        
        realCompletion([model.paraKey : model.paraValue as AnyObject] , model.value , true)
    }
}

extension FilterContentTableView : FilterContentInstaller
{
    func configPrePara(_ preParas: [String: Any]?) -> Bool {
        
        guard let realPara = preParas else { return false }
        
        var paraContains = false
        
        for model in filterContentModels
        {
            if realPara.keys.contains(model.paraKey)
            {
                let result = model.paraValue == realString(realPara[model.paraKey])
                if result
                {
                    selectedTitle = model.value
                    paraContains = true
                    containedPara[model.paraKey] = model.paraValue as AnyObject?
                }
                model.isSelect = result
            }
            else
            {
                model.isSelect = false
            }
        }
        
        tableView.reloadData()
        
        containsPrePara = paraContains
        
        return paraContains
    }
}
