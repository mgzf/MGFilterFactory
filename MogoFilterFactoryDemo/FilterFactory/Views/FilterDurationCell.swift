//
//  FilterDurationCell.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/21.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class FilterDurationCell: BaseFilterCollectionCell {
    
    var isStartRunning : Bool = false
    
    @IBOutlet weak var startPlaceHolderLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endPlaceHolderLabel: UILabel!
    
    @IBOutlet weak var startBtn: BasePopButton!
        {
        didSet
        {
            startBtn.layer.cornerRadius = 5
            startBtn.layer.borderWidth = 1/UIScreen.main.scale
            startBtn.layer.borderColor = UIColor.lightGray.cgColor
            startBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                
                self.isStartRunning = true
                
                self.showCalendar()
                
            }).addDisposableTo(disposeBag)
        }
    }
    
    @IBOutlet weak var endBtn: BasePopButton!
        {
        didSet
        {
            endBtn.layer.cornerRadius = 5
            endBtn.layer.borderWidth = 1/UIScreen.main.scale
            endBtn.layer.borderColor = UIColor.lightGray.cgColor
            endBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                
                self.isStartRunning = false
                
                self.showCalendar()
                
            }).addDisposableTo(disposeBag)
        }
    }
    
    fileprivate func showCalendar()
    {
        self.superview?.endEditing(true)
        
        if let config = filterSectionConfig
        {
            if isStartRunning
            {
                if let startDate = config.startDate
                {
                    datePicker.date = startDate as Date!

                }

            }
            else
            {
                if let endDate = config.endDate
                {
                    datePicker.date = endDate as Date!
                }
            }
            
            config.isRunning = true
//            datePicker.setDateRangeFrom(config.startDate, toDate: config.endDate)
        }
        if self.viewController()?.view.frame.size.height < kScreenHeight
        {
            UIApplication.shared.keyWindow?.rootViewController!.presentSemiViewController(self.datePicker, withOptions:[
                KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(value: false as Bool),
                KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.4 as Float),
                KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(value: 0.3 as Float)
                ])
        }
        else
        {
            self.viewController()?.presentSemiViewController(self.datePicker, withOptions: [
                KNSemiModalOptionKeys.pushParentBack.takeRetainedValue()    : NSNumber(value: false as Bool),
                KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.4 as Float),
                KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue()     : NSNumber(value: 0.3 as Float)
                ])
        }

        
    }
    
    lazy var datePicker:THDatePickerViewController = {
        var dp = THDatePickerViewController.datePicker()
        dp?.delegate = self
        dp?.dateTimeZone = TimeZone.current
        dp?.setAllowClearDate(false)
        dp?.setClearAsToday(true)
        dp?.setAutoCloseOnSelectDate(false)
        dp?.setAllowSelectionOfSelectedDate(true)

        dp?.selectedBackgroundColor = UIColor(red: 125/255.0, green: 208/255.0, blue: 0/255.0, alpha: 1.0)
        dp?.currentDateColor = UIColor(red: 242/255.0, green: 121/255.0, blue: 53/255.0, alpha: 1.0)
        dp?.currentDateColorSelected = UIColor.yellow
        dp?.date = Date(timeIntervalSinceNow: 0)

        return dp!
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    var filterSectionConfig : CommonFilterConfigSectionModel?
        {
        didSet
        {
            guard let config = filterSectionConfig else { return }
            
            config.variableStartDate.asDriver()
                .drive(startDateLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            config.variableEndDate.asDriver()
                .drive(endDateLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            func resetStart()
            {
                startDateLabel.text = "最早日期  ▾"
                startDateLabel.textColor = UIColor.lightGray
            }
            
            func resetEnd()
            {
                endDateLabel.text = "最晚日期  ▾"
                endDateLabel.textColor = UIColor.lightGray
            }
            
            Observable.combineLatest(config.variableStartDate.asObservable(), config.variableEndDate.asObservable()) {[weak self] (start, end) -> Bool in
                guard let `self` = self else { return true }
                if start.isEmpty
                {
                    resetStart()
                }
                
                if end.isEmpty
                {
                    resetEnd()
                }
                
                guard let startDate = dateFormatter.date(from: start) else { return true }
                
                guard let endDate = dateFormatter.date(from: end) else { return true }
                
                self.startDateLabel.textColor = UIColor.darkGray
                self.endDateLabel.textColor = UIColor.darkGray
                return startDate.timeIntervalSince(endDate) <= 0
            }.subscribe(onNext: { (next) in
                config.isValid = next
            }).addDisposableTo(disposeBag)
            
            
            startDateLabel.text = "最早日期  ▾"
            endDateLabel.text = "最晚日期  ▾"
            
            if let startDate = config.startDate
            {
                startDateLabel.text = dateFormatter.string(from: startDate)
                startDateLabel.textColor = UIColor.darkGray
            }
            
            if let endDate = config.endDate
            {
                endDateLabel.text = dateFormatter.string(from: endDate)
                endDateLabel.textColor = UIColor.darkGray
            }
        }
    }

}

extension FilterDurationCell : THDatePickerDelegate
{
    func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        let date:Date! = datePicker.date
        let zone:TimeZone! = TimeZone.current
        let interval:Double! = Double(zone.secondsFromGMT(for: date))
        let selectDate:Date! = date.addingTimeInterval(interval)
        let strSelectDate = dateFormatter.string(from: selectDate)
        print(strSelectDate)
        
        
        if let config = filterSectionConfig
        {
            if isStartRunning
            {
                config.startDate = date
                startDateLabel.textColor = UIColor.darkGray
            }
            else
            {
                config.endDate = date
                endDateLabel.textColor = UIColor.darkGray
            }
        }

        
        datePicker.dismissSemiModalView()
    }
    
    func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        datePicker.dismissSemiModalView()
    }
}
