//
//  FilterDialogChoiceCell.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/21.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit

class FilterDialogChoiceCell: BaseFilterCollectionCell {
    
    var choiceVc = TableSelectionViewController(nibName: "TableSelectionViewController", bundle: nil)
    
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
        {
        didSet
        {
            selectBtn.layer.borderColor = UIColor.lightGray.cgColor
            selectBtn.layer.cornerRadius = 5
            
            selectBtn.layer.borderWidth = 1/UIScreen.main.scale
            
            selectBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.superview?.endEditing(true)

                self.choiceVc.clickCB = {[weak self] (selectData) in
                    guard let `self` = self else { return }

                    guard let config = self.filterSectionConfig else { return }

                    guard let dataSource = config.internalArray else { return }

                    config.isRunning = true

                    self.selectedLabel.text = selectData["value"] as? String

                    config.realText = selectData["value"] as? String

                    self.selectedLabel.textColor = UIColor.darkGray

                    dataSource.forEach({ (model) in
                        if model.value == selectData["value"] as! String
                        {
                            model.isSelect = true
                        }
                        else
                        {
                            model.isSelect = false
                        }
                    })
                }

                if (self.viewController()?.view.frame.size.height)! < kScreenHeight
                {
                    UIApplication.shared.keyWindow?.rootViewController!.presentSemiViewController(self.choiceVc, withOptions: [
                        KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(value: false),
                        KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.4),
                        KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(value: 0.3)
                        ])
                }
                else
                {
                    self.viewController()?.presentSemiViewController(self.choiceVc, withOptions: [
                        KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(value: false),
                        KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.4),
                        KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(value: 0.3)
                        ])
                }
//                print((self.viewController?.view.description)! + "***\(kScreenHeight)")
                guard let config = self.filterSectionConfig else { return }
                
                guard let dataSource = config.internalArray else { return }
                
                let selectedSources = dataSource.filter { $0.isSelect }
                
                if selectedSources.count == 0
                {
                    self.choiceVc.resetTableView()
                }
            }).addDisposableTo(disposeBag)
            
            
            
//            selectBtn.rx_tap.subscribeNext {[weak self] (_) in
//                guard let `self` = self else { return }
//                
//                self.superview?.endEditing(true)
//
//                self.choiceVc.clickCB = {[weak self] (selectData) in
//                    guard let `self` = self else { return }
//                    
//                    guard let config = self.filterSectionConfig else { return }
//                    
//                    guard let dataSource = config.internalArray else { return }
//                    
//                    config.isRunning = true
//                    
//                    self.selectedLabel.text = selectData["value"] as? String
//                    
//                    config.realText = selectData["value"] as? String
//                    
//                    self.selectedLabel.textColor = UIColor.darkGrayColor()
//                    
//                    dataSource.forEach({ (model) in
//                        if model.value == selectData["value"] as! String
//                        {
//                            model.isSelect = true
//                        }
//                        else
//                        {
//                            model.isSelect = false
//                        }
//                    })
//                }
//                
//                if self.viewController?.view.frame.size.height < kScreenHeight
//                {
//                    UIApplication.sharedApplication().keyWindow?.rootViewController!.presentSemiViewController(self.choiceVc, withOptions: [
//                        KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(bool: false),
//                        KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(float: 0.4),
//                        KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(float: 0.3)
//                        ])
//                }
//                else
//                {
//                    self.viewController?.presentSemiViewController(self.choiceVc, withOptions: [
//                        KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(bool: false),
//                        KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(float: 0.4),
//                        KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(float: 0.3)
//                        ])
//                }
////                print((self.viewController?.view.description)! + "***\(kScreenHeight)")
//                guard let config = self.filterSectionConfig else { return }
//                
//                guard let dataSource = config.internalArray else { return }
//                
//                let selectedSources = dataSource.filter { $0.isSelect }
//                
//                if selectedSources.count == 0
//                {
//                    self.choiceVc.resetTableView()
//                }
//                
//            }.addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        selectBtn.rx.tap.
        // Initialization code
    }
    
    var filterSectionConfig : CommonFilterConfigSectionModel?
        {
        didSet
        {
            guard let config = filterSectionConfig else { return }
            
            selectedLabel.text = config.placeHolderName
            selectedLabel.textColor = UIColor.lightGray
            if let real = config.realText
            {
                selectedLabel.text = real
                selectedLabel.textColor = UIColor.darkGray
            }
            
            guard let dataSource = config.internalArray else { return }
            
            self.choiceVc.dataSource = dataSource.map { ["value" : $0.value as AnyObject] }
            
            self.choiceVc.displayKey = "value"
        }
    }


}
