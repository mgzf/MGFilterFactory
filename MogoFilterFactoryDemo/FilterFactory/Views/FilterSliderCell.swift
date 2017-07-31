//
//  FilterSliderCell.swift
//  MogoPartner
//
//  Created by 刘明杰 on 2017/7/19.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift

class FilterSliderCell: BaseFilterCollectionCell {

    @IBOutlet weak var rangeSlider: TTRangeSlider!{
        didSet{
            rangeSlider.isUserInteractionEnabled = true
            rangeSlider.isEnabledIntersect = true
            rangeSlider.displayMaxMinValue = false
            rangeSlider.delegate = self
            rangeSlider.rangeColor = UIColor.rgbColor(r:246, g: 80, b: 0)
            rangeSlider.trackColor = UIColor.rgbColor(r:219, g: 219, b: 219)
            rangeSlider.tintColor = UIColor.rgbColor(r:102, g: 102, b: 102)
            rangeSlider.minValue = 0
            rangeSlider.maxValue = 10000
            rangeSlider.selectedMinimum = 0
            rangeSlider.selectedMaximum = 10000
            rangeSlider.enableStep = true
            rangeSlider.step = 100
            rangeSlider.hiddenMaxMinLabel = false
        }
    }
    
    var filterSectionConfig : CommonFilterConfigSectionModel?{
        didSet
        {
            guard let config = filterSectionConfig else { return }
            
            func resetMinMoney()
            {
                rangeSlider.selectedMinimum = 0
            }
            
            func resetMaxMoney()
            {
                rangeSlider.selectedMaximum = 10000
            }
            
            Observable.combineLatest(config.variableMinMoney.asObservable(), config.variableMaxMoney.asObservable()) {[unowned self] (minMoney, maxMoney) -> Bool in
                if minMoney == -1
                {
                    resetMinMoney()
                    config.minMoney = Int(self.rangeSlider.selectedMinimum)
                }
                
                if maxMoney == -1
                {
                    resetMaxMoney()
                    config.maxMoney = Int(self.rangeSlider.selectedMaximum)
                }
                
                return true
                }.subscribe(onNext: { (next) in
                    config.isValid = next
                }).addDisposableTo(disposeBag)
            
            rangeSlider.selectedMinimum = 0
            rangeSlider.selectedMaximum = 10000
            
            if let minMoney = config.minMoney
            {
                rangeSlider.selectedMinimum = Float(minMoney)
            }
            
            if let maxMoney = config.maxMoney
            {
                rangeSlider.selectedMaximum = Float(maxMoney)
                if maxMoney == 0{
                    rangeSlider.selectedMaximum = 10000
                }
            }
        }

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension FilterSliderCell: TTRangeSliderDelegate
{
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        guard let config = filterSectionConfig else { return }
        config.minMoney = Int(selectedMinimum)
        config.maxMoney = Int(selectedMaximum)
        
    }
}
/**
 
 */
