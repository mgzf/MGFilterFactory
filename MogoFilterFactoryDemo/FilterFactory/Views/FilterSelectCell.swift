//
//  FilterSelectCell.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift

class FilterSelectCell: BaseFilterCollectionCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var titleLabel: UILabel!
    
    var filterConfig : ConfigModel?
        {
        didSet
        {
            guard let config = filterConfig else { return }
            titleLabel.text = config.value
            
            if config.isSelect {
                self.selectedStyle()
            }
            else
            {
                self.deSelectStyle()
            }
            
            if config.shouldReDefineRxInCell
            {
               config.variableSelected = Variable(config.isSelect)
            }
            
            config.variableSelected.asObservable().subscribe(onNext: {[weak self] (selected) in
                guard let `self` = self else { return }
                if selected
                {
                    self.selectedStyle()
                }
                else
                {
                    self.deSelectStyle()
                }
            }).addDisposableTo(disposeBag)
        }
    }
    
    func selectedStyle()
    {
        titleLabel.textColor = kColor_orange
        titleLabel.layer.borderWidth = 1 / UIScreen.main.scale
        titleLabel.layer.borderColor = kColor_orange.cgColor
    }
    
    func deSelectStyle()
    {
        titleLabel.textColor = UIColor.darkGray
        titleLabel.layer.borderWidth = 1 / UIScreen.main.scale
        titleLabel.layer.borderColor = UIColor.lightGray.cgColor
    }
}
