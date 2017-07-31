//
//  CommonConfigCell.swift
//  MogoPartner
//
//  Created by Harly on 2017/2/21.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit

class CommonConfigCell: UITableViewCell {

    @IBOutlet weak var configTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    var model : ConfigModel?
        {
        didSet
        {
            guard let realModel = model else { return }
            
            configTitleLabel.text = realModel.value
            
            if realModel.isSelect
            {
                configTitleLabel.textColor = kColor_partnerBlue
                
            }
            else
            {
                configTitleLabel.textColor = kColor_darkTextColor
            }
        }
    }
    
    
}
