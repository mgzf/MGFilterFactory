//
//  CommonFilterHeaderCell.swift
//  MogoPartner
//
//  Created by Harly on 2017/2/20.
//  Copyright © 2017年 mogoroom. All rights reserved.
//

import UIKit

class CommonFilterHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var filter : CommonFilterConfigSectionModel?
        {
        didSet
        {
            guard let realFilter = filter else { return }
            filterTitleLabel.text = realFilter.sectionName
            
            if realFilter.isValid || realFilter.isRunning
            {
                filterTitleLabel.textColor = kColor_partnerBlue
            }
            else
            {
                filterTitleLabel.textColor = kColor_darkTextColor
            }
            
            if realFilter.isRunning
            {
                filterTitleLabel.text = realFilter.sectionName + " ▴"
            }
            else
            {
                filterTitleLabel.text = realFilter.sectionName + " ▾"
            }
        }
    }
}
