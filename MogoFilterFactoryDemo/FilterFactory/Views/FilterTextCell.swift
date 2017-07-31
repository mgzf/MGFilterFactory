//
//  FilterTextCell.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift

class FilterTextCell: BaseFilterCollectionCell {
    @IBOutlet weak var textLabel: UITextField!
        {
        didSet
        {
            textLabel.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var filterSectionConfig : CommonFilterConfigSectionModel?
        {
        didSet
        {
            guard let config = filterSectionConfig else { return }
            
            if let defaultValue =  config.defaultValue
            {
                textLabel.text = defaultValue
            }
            
            if let real =  config.realText
            {
                textLabel.text = real
            }
            
            if let placeHolder = config.placeHolderName
            {
                textLabel.placeholder = placeHolder
            }
            
            if let regexValue = config.regex
            {
                textLabel.rx.text.subscribe(onNext: {[weak self] (text) in
                    guard let `self` = self else { return }
                    config.isRunning = true
                    if (text?.isEmpty)!
                    {
                        config.realText = text
                        config.isValid = true
                        return
                    }
                    do {
                        
                        if regexValue.isEmpty
                        {
                            config.isValid = true
                        }
                        else
                        {
                            let pattern: String = regexValue
                            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
                            let matches = regex.matches(in: text!, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (text?.characters.count)!))
                            config.isValid = matches.count > 0
                        }
                        
                    }
                    catch {
                        config.isValid = false
                    }
                    
                    if config.isValid
                    {
                        config.realText = text
                    }
                }).addDisposableTo(disposeBag)
            }
        }
    }
    //    var filterConfig : ConfigModel?
    //        {
    //        didSet
    //        {
    //            guard let config = filterConfig else { return }
    //            titleLabel.text = config.value
    //        }
    //    }
    
}
