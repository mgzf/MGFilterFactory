//
//  TitledHeader.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TitledHeader: UICollectionReusableView {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var filterSectionConfig : CommonFilterConfigSectionModel?
        {
        didSet
        {
            guard let config = filterSectionConfig else { return }
            
            titleLabel.text = config.sectionName
            
            config.variableValid.asDriver()
                .drive(errorLabel.rx.isHidden)
                .addDisposableTo(disposeBag)
            
            config.variableErrorMessage.asDriver()
                .drive(errorLabel.rx.text)
                .addDisposableTo(disposeBag)
        }
    }
    
}
