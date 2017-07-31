//
//  CommonFilterConfigModel.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift

enum SectionType : Int {
    
    /// 单选
    case singleChoice = 0
    
    /// 多选
    case multipleChoice
    
    /// 输入框
    case inputText
    
    /// 弹框选择
    case dialogChoice
    
    /// 单选日期
    case singleDatePick
    
    /// 双选日期
    case durationDatePick
    
    /// 筛选框
    case filterPicker
    
    /// 强制单选（重置之后常亮第一个选项即“全部”）
    case strongSingleChoice
    
    /// funny 滑杆
    case slider
    
    /// 再见
    case notSupported
    
}

let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

class CommonFilterConfigSectionModel : NSObject {
    
    var shouldConvertToBool = false
    var needHide : Bool = false
    
    var priority : NSNumber?
        {
        didSet
        {
            if let pri = priority
            {
                conifgPriority = pri.intValue
            }
        }
    }
    
    var permissions : [NSNumber]?
        {
        didSet
        {
            if let realPermissions = permissions
            {
                conifgPermissions = realPermissions.map { $0.intValue }
            }
        }
    }
    
    var conifgPermissions : [Int]?
    
    var conifgPriority : Int?
    
    var sectionParaKey: String = "'"
    var sectionSubParaKey: String = "'"
    
    var sectionId : String = "0"
    var sectionName : String = "Not supported"
    var sectionType : SectionType!
    var sectionTypeNumber : Int = 0
        {
            didSet
            {
                sectionType = SectionType(rawValue: sectionTypeNumber)
        }
    }
    var isValid : Bool = true
        {
        didSet
        {
            variableValid.value = isValid
        }
    }
    var variableValid = Variable(true)
    
    var isRunning : Bool = false
        {
        didSet
        {
            variableRunning.value = isRunning
        }
    }
    var variableRunning = Variable(true)
    
    var errorMessage : String = ""
        {
            didSet
            {
                variableErrorMessage.value = errorMessage
        }
    }
    
    var variableErrorMessage = Variable("")
    
    /// 多选框
    var internalArray : [ConfigModel]?
    
    /// 文本框
    var placeHolderName : String?
    var defaultValue : String?
    var regex : String?
    var realText : String?
    
    /// 日期系列
    var startDateHolder : String? = "最早日期"
    var endDateHolder : String? = "最晚日期"
    
    /// 租金范围
//    var minMoney:Int? = 0
//    var maxMoney:Int? = 0
    
    var variableMinMoney = Variable(0)
    var minMoney : Int?
    {
        didSet
        {
            if let money = minMoney
            {
                variableMinMoney.value = money
            }
            else
            {
                variableMinMoney.value = 0
            }
        }
    }
    
    var variableMaxMoney = Variable(10000)
    var maxMoney : Int?
    {
        didSet
        {
            if let money = maxMoney
            {
                variableMaxMoney.value = money
            }
            else
            {
                variableMaxMoney.value = 10000
            }
        }
    }
    
    
    var variableStartDate = Variable("")
    var startDate : Date?
        {
        didSet
        {
            if let date = startDate
            {
                let dateString = dateFormatter.string(from: date)
                variableStartDate.value = dateString
            }
            else
            {
                variableStartDate.value = ""
            }
        }
    }
    
    var variableEndDate = Variable("")
    var endDate : Date?
        {
        didSet
        {
            if let date = endDate
            {
                let dateString = dateFormatter.string(from: date)
                variableEndDate.value = dateString
            }
            else
            {
                variableEndDate.value = ""
            }
        }
    }
    
    var otherString: String = "'"
    
    init(dic : NSDictionary) {
        super.init()
        self.setValuesForKeys(dic as! [String: Any])
        if let conifgedArray = dic["internalArray"] as? [[String: Any]]
        {
            internalArray = conifgedArray.map { ConfigModel(dic : $0 as NSDictionary) }
        }
//        internalArray = [ConfigModel(ignoreAll : true , isSelect : false ,key: "1", value: "全部"),
//        ConfigModel(key: "2", value: "全部12222"),
//        ConfigModel(key: "3", value: "全部212"),
//        ConfigModel(key: "4", value: "全部3aaaaaa"),
//        ConfigModel(key: "5", value: "全部4ss"),
//        ConfigModel(key: "6", value: "全部ffff5"),
//        ConfigModel(key: "7", value: "全部aaa6"),
//        ConfigModel(key: "8", value: "全部s7")]
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
