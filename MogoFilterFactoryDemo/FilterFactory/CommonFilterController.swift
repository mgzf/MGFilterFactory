//
//  CommonFilterController.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/20.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import RxSwift
import ActionStageSwift

class CommonFilterController: BaseViewController
{
    // MARK: -
    
    var archiveKey: String? = nil
    var preParameters: [String: Any]? = nil
    var containedPara = [String: Any]()
    
    var containsPrePara : Bool = false
    var forceUnlit: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleView: UIView!
    
    var filterCompletion : (([String: Any], String?, Bool)->Void)?
    
    /// 筛选tag，可以不鸟
    var filterTag = -99
    
    /// 权限控制，仅当单选／多选时有效
    var currentPriority = 0
    var currentPermission = [Int]()
    
    /// 筛选项高度
    let filterItemHeight : CGFloat = 35
    
    /// head项高度
    let headHeight : CGFloat = 35
    
    var filterViewModel = CommonFilterViewModel(filterFileName: "sampleFilterConfig")
    
    var originalFilterSections = [CommonFilterConfigSectionModel]()
    
    fileprivate var onCompletion : (([String: Any] , Bool)->())?
    
    // MARK: - 共通buttons
    @IBOutlet weak var cancelBtn: UIButton!
        {
        didSet
        {
            cancelBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
                }).addDisposableTo(disposeBag)
        }
    }
    
    @IBOutlet weak var resetBtn: UIButton!
        {
        didSet
        {
            resetBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.filterViewModel.commonFilters.forEach { (sectionFilter) in
                    guard let type = sectionFilter.sectionType else { return }
                    guard !sectionFilter.sectionParaKey.isEmpty else { return }
                    
                    sectionFilter.realText = nil
                    
                    switch type{
                        
                    //重置多选
                    case.multipleChoice , .singleChoice , .dialogChoice:
                        if let internalArray = sectionFilter.internalArray
                        {
                            internalArray.forEach({ (model) in
                                model.isSelect = false
                                //                                model.variableSelected = Variable(false)
                            })
                        }
                    //重置多选
                    case.strongSingleChoice:
                        if let internalArray = sectionFilter.internalArray
                        {
                            internalArray.forEach({ (model) in
                                model.isSelect = false
                                //                                model.variableSelected = Variable(false)
                            })
                            if let firstModel:ConfigModel = internalArray.first
                            {
                                firstModel.isSelect = true
                            }
                        }
                    case.durationDatePick:
                        sectionFilter.startDate = nil
                        sectionFilter.endDate = nil
                    case.inputText:
                        sectionFilter.realText = ""
                    case .slider:
                        sectionFilter.minMoney = -1
                        sectionFilter.maxMoney = -1
                    default:
                        return
                    }
                }
                
                self.filterViewModel.commonFilters = self.originalFilterSections
                self.filterCollectionView.reloadData()
                }).addDisposableTo(disposeBag)
            
        }
    }
    @IBOutlet weak var commitBtn: UIButton!
        {
        didSet
        {
            commitBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                
                var commitParameters = [String: Any]()
                var hasError = false
                self.filterViewModel.commonFilters.forEach { (sectionFilter) in
                    guard let type = sectionFilter.sectionType else { return }
                    guard !sectionFilter.sectionParaKey.isEmpty else { return }
                    
                    guard sectionFilter.isValid else
                    {
                        MGProgressHUD.showTextAndHiddenView(sectionFilter.errorMessage)
                        hasError = true
                        return
                    }
                    
                    switch type {
                        
                    //多选整合
                    case .multipleChoice:
                        if let internalArray = sectionFilter.internalArray
                        {
                            let paras = internalArray.filter { $0.isSelect }.map { $0.paraValue }
                            if paras.count != 0
                            {
                                commitParameters[sectionFilter.sectionParaKey] = paras as AnyObject?
                            }
                        }
                    //单选的整合,对话框整合
                    case .singleChoice, .dialogChoice:
                        if let internalArray = sectionFilter.internalArray
                        {
                            let paraArray = internalArray.filter { $0.isSelect }
                            
                            if paraArray.count == 1 {
                                self.forceUnlit = paraArray.first!.value == "全部"
                            }
                            
                            let paras = paraArray.map { $0.paraValue }
                            if paras.count != 0
                            {
                                if let paraString = paras.first, !paraString.isEmpty
                                {
                                    commitParameters[sectionFilter.sectionParaKey] = paraString as AnyObject?
                                }
                            }
                        }
                    //强制单选
                    case .strongSingleChoice:
                        if let internalArray = sectionFilter.internalArray
                        {
                            let paras = internalArray.filter { $0.isSelect }.filter {$0.value != internalArray.first?.value}.map { $0.paraValue }
                            if paras.count != 0
                            {
                                if let paraString = paras.first, !paraString.isEmpty
                                {
                                    commitParameters[sectionFilter.sectionParaKey] = paraString as AnyObject?
                                }
                            }
                        }
                    //输入框整合
                    case .inputText:
                        if let iputText = sectionFilter.realText, !iputText.isEmpty
                        {
                            commitParameters[sectionFilter.sectionParaKey] = iputText as AnyObject?
                        }
                        else
                        {
                            commitParameters.removeValue(forKey: sectionFilter.sectionParaKey)
                        }
                    //起止时间整合
                    case .durationDatePick:
                        if let startDate = sectionFilter.startDate
                        {
                            commitParameters[sectionFilter.sectionParaKey] =  dateFormatter.string(from: startDate) as AnyObject?
                        }
                        
                        if let endDate = sectionFilter.endDate
                        {
                            if !sectionFilter.sectionSubParaKey.isEmpty
                            {
                                commitParameters[sectionFilter.sectionSubParaKey] = dateFormatter.string(from: endDate) as AnyObject?
                            }
                        }
                    case .slider:
                        if let minMoney = sectionFilter.minMoney
                        {
                            commitParameters[sectionFilter.sectionParaKey] = minMoney as AnyObject?
                        }
                        
                        if let maxMoney = sectionFilter.maxMoney
                        {
                            if !sectionFilter.sectionSubParaKey.isEmpty
                            {
                                commitParameters[sectionFilter.sectionSubParaKey] = maxMoney as AnyObject?
                                if maxMoney == 10000{
                                    commitParameters[sectionFilter.sectionSubParaKey] = 0 as AnyObject?
                                }
                            }
                        }
                    default:
                        return
                    }
                    
                }
                
                self.preParameters = commitParameters
                if self.archiveFilterConfigs(commitParameters) == false {
                    Logger.debug("Archive filter config failed")
                }
                
                guard !hasError else { return }
                
                let highlight: Bool = self.forceUnlit ? false : commitParameters.count != 0
                
                if let completion = self.onCompletion
                {
                    completion(commitParameters , highlight)
                }
                
                self.dismiss(animated: true, completion: nil)
                
                
                guard let realCompletion = self.filterCompletion else { return }
                
                realCompletion(commitParameters, nil, highlight)
                
                }).addDisposableTo(disposeBag)
            
        }
    }
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
        {
        didSet
        {
            filterCollectionView.register(UINib(nibName: "FilterSelectCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterSelectCell")
            
            filterCollectionView.register(UINib(nibName: "FilterTextCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterTextCell")
            
            filterCollectionView.register(UINib(nibName: "FilterDurationCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterDurationCell")
            
            filterCollectionView.register(UINib(nibName: "FilterDialogChoiceCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterDialogChoiceCell")
            
            filterCollectionView.register(UINib(nibName: "FilterSliderCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterSliderCell")
            
            filterCollectionView.register(UINib(nibName: "TitledHeader", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TitledHeader")
            
            
            let tapGesture = UITapGestureRecognizer()
            tapGesture.delegate = self
            filterCollectionView.addGestureRecognizer(tapGesture)
            
            //            filterCollectionView.tapGestureWithBlock {[weak self] in
            //                guard let `self` = self else { return }
            //                self.view.endEditing(true)
            //            }
        }
    }
    
    /// 底部区域
    @IBOutlet weak var operationViews: UIView!
        {
        didSet
        {
            //            UIViewComHelper.setShadowForView(operationViews , needCornerRadius : false)
        }
        
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if needHideTitle
        {
            hideTitleView()
        }
        
        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !needHideTitle
        {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
        
        if preParameters != nil {
            configPrePara(preParameters)
            filterCollectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(false)
    }
    
    // MARK: - 初始化方法
    /// 神奇的初始方法
    ///
    /// - Parameters:
    ///   - filterPlist: filterPlist，参考sampleFilterConfig
    ///   - configuration: 配置回调
    init(filterPlist : String , preParas : [String: Any]? = nil , archiveKey: String? = nil,
         withConfiguration configuration: ((_ config : CommonFilterConfigSectionModel) -> ())?,
                           onCompletion completion :(([String: Any],Bool)->())? = nil)
    {
        self.archiveKey = archiveKey
        super.init(nibName: "CommonFilterController", bundle: Bundle.main)
        
        filterViewModel = CommonFilterViewModel(filterFileName: filterPlist)
        
        if filterViewModel.commonFilters.count != 0
        {
            filterViewModel.commonFilters.forEach({ (model) in
                if let realConfiguration = configuration
                {
                    realConfiguration(model)
                }
                
                //注册所有filter的 isruuning，当某个section使用时候自动变true并把别的变为false
                
                model.variableRunning.asObservable().subscribe(onNext: {[weak self] (isRunning) in
                    guard let `self` = self else { return }
                    if isRunning
                    {
                        self.filterViewModel.commonFilters.forEach({ (otherModel) in
                            if otherModel != model
                            {
                                otherModel.isRunning = false
                            }
                        })
                    }
                }).addDisposableTo(self.disposeBag)
            })
            originalFilterSections = filterViewModel.commonFilters
        }
        
        
        if let realCompletion = completion
        {
            onCompletion = realCompletion
        }
        
        let maxPrioSection = filterViewModel.commonFilters.max { (first, last) -> Bool in
            guard let firstPrio = first.conifgPriority else { return false }
            guard let lastPrio = last.conifgPriority else { return false }
            return firstPrio <= lastPrio
        }
        
        if let maxPrioSec = maxPrioSection
        {
            //如果最高权限项存在则自动将其变为running
            maxPrioSec.isRunning = true
        }
        
        
        if let maxPer = maxPrioSection?.conifgPriority
        {
            currentPriority = maxPer
            
            if let perm = maxPrioSection?.conifgPermissions
            {
                currentPermission = perm
                permissionVerify()
            }
            else
            {
                if let internalArray = maxPrioSection?.internalArray
                {
                    let models = internalArray.filter { $0.isSelect }
                    models.forEach({[weak self] (model) in
                        guard let `self` = self else { return }
                        if let perms = model.conifgPermissions
                        {
                            self.currentPermission.append(contentsOf: perms)
                        }
                        })
                }
                
                permissionVerify()
            }
            
        }
        
        if preParas != nil {
            preParameters = preParas
        } else {
            preParameters = loadFilterConfigs()
        }
        
//        configPrePara(preParameters)
    }
    
    
    /// 神奇的再配置方法，配置完了会自动刷新
    ///
    /// - Parameter configuration: 配置回调
    func reConfigSections(_ configuration: ((_ config : CommonFilterConfigSectionModel) -> ())?)
    {
        guard filterViewModel.commonFilters.count != 0 else { return }
        
        filterViewModel.commonFilters.forEach({ (model) in
            if let realConfiguration = configuration
            {
                realConfiguration(model)
            }
        })
        
        originalFilterSections = filterViewModel.commonFilters
        
        filterCollectionView.reloadData()
    }
    
    var needHideTitle = false
    
    func hideTitleView()
    {
        titleHeightConstraint.constant = 0
        titleView.isHidden = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
}

// MARK: - Gesture Delegates
extension CommonFilterController: UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        view.endEditing(true)
        return false
    }
    
}

// MARK: - CollectionView Delegates
extension CommonFilterController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterViewModel.commonFilters.filter { !$0.needHide }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNumbersOfSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TitledHeader", for: indexPath) as! TitledHeader
        let filter = filterViewModel.commonFilters.filter { !$0.needHide }[indexPath.section]
        view.filterSectionConfig = filter
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: headHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return cellForIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectRowAtIndexPath(indexPath)
    }
}

extension CommonFilterController : FilterContentInstaller
{
    /// 配置初始参数
    ///
    /// - Parameter preParas: paras
    @discardableResult
    func configPrePara(_ preParas : [String: Any]?) -> Bool
    {
        guard let realPrePara = preParas else { return false }
        
        var containsPara = false
        
        for sectionFilter in filterViewModel.commonFilters
        {
            guard realPrePara.keys.contains(sectionFilter.sectionParaKey)
                || realPrePara.keys.contains(sectionFilter.sectionSubParaKey) else { continue }
            
            
            guard let type = sectionFilter.sectionType else { continue }
            switch type{
            case .singleChoice,
                 .strongSingleChoice,
                 .multipleChoice:
                if let internalArray = sectionFilter.internalArray
                {
                    var isAll = false
                    if let arrayPara = realPrePara[sectionFilter.sectionParaKey] as? [String]
                    {
                        internalArray.forEach({ (model) in
                            model.isSelect = false
                            if arrayPara.contains(model.paraValue)
                            {
                                model.isSelect = true
                                containedPara[sectionFilter.sectionParaKey] = model.paraValue as AnyObject?
                                containsPara = true
                                if !model.ignoreAll
                                {
                                    isAll = false
                                }
                            }
                        })
                    }
                    else if let stringPara = realString(realPrePara[sectionFilter.sectionParaKey]) as? String
                    {
                        internalArray.forEach({ (model) in
                            model.isSelect = false
                            if stringPara == model.key
                            {
                                model.isSelect = true
                                containedPara[sectionFilter.sectionParaKey] = model.paraValue as AnyObject?
                                containsPara = true
                                if !model.ignoreAll
                                {
                                    isAll = false
                                }
                            }
                        })
                    }
                    
                    if !isAll
                    {
                        internalArray.forEach({ (model) in
                            if model.ignoreAll
                            {
                                model.isSelect = false
                            }
                        })
                    }
                }
                
            case .inputText:
                let defaultText = realString(realPrePara[sectionFilter.sectionParaKey])
                sectionFilter.defaultValue = defaultText
                containedPara[sectionFilter.sectionParaKey] = defaultText as AnyObject?
                
                //                case .DialogChoice:
                //
            //
            case .durationDatePick:
                if let startString = realString(realPrePara[sectionFilter.sectionParaKey]), !startString.isEmpty
                {
                    containsPara = true
                    sectionFilter.startDate = dateFormatter.date(from: startString)
                    containedPara[sectionFilter.sectionParaKey] = startString as AnyObject?
                }
                
                if let endString = realString(realPrePara[sectionFilter.sectionSubParaKey]), !endString.isEmpty
                {
                    containsPara = true
                    sectionFilter.endDate = dateFormatter.date(from: endString)
                    containedPara[sectionFilter.sectionSubParaKey] = endString as AnyObject?
                }
            case .dialogChoice:
                if let internalArray = sectionFilter.internalArray
                {
                    if let stringPara = realString(realPrePara[sectionFilter.sectionParaKey]) as? String
                    {
                        internalArray.forEach({ (model) in
                            model.isSelect = false
                            if stringPara == model.key
                            {
                                sectionFilter.realText = model.value
                                model.isSelect = true
                                containedPara[sectionFilter.sectionParaKey] = model.paraValue as AnyObject?
                                containsPara = true
                            }
                        })
                    }
                }
            case .slider:
                if let minMoney:Int = realPrePara[sectionFilter.sectionParaKey] as? Int
                {
                    containsPara = true
                    sectionFilter.minMoney = minMoney
                    containedPara[sectionFilter.sectionParaKey] = minMoney as AnyObject?
                }
                
                if let maxMoney:Int = realPrePara[sectionFilter.sectionSubParaKey] as? Int
                {
                    containsPara = true
                    sectionFilter.maxMoney = maxMoney
                    containedPara[sectionFilter.sectionSubParaKey] = maxMoney as AnyObject?
                    if maxMoney == 0{
                        containedPara[sectionFilter.sectionSubParaKey] = 10000 as AnyObject?
                    }
                }

            default:
                continue
            }
            
        }
        
        containsPrePara = containsPara
        return containsPara
    }
    
}

// MARK: - CollectionView VM Helpers
extension CommonFilterController
{
    
    /// 通过section获得cell items count
    ///
    /// - Parameter section: section
    /// - Returns: items
    fileprivate func filterNumbersOfSection(_ section : Int) -> Int
    {
        let sectionFilter = filterViewModel.commonFilters.filter { !$0.needHide }[section]
        
        guard let type = sectionFilter.sectionType else { return 0 }
        switch type{
        case .singleChoice,
             .strongSingleChoice,
             .multipleChoice:
            if let internalArray = sectionFilter.internalArray
            {
                return internalArray.filter { !$0.needHide }.count
            }
            else
            {
                return 0
            }
        case .dialogChoice ,
             .durationDatePick,
             .singleDatePick,
             .slider,
             .inputText:
            return 1
        default:
            return 0
        }
    }
    
    /// 指定IndexPath大小
    ///
    /// - Parameter path: indexPath
    /// - Returns: size
    fileprivate func sizeForIndexPath(_ path : IndexPath) -> CGSize
    {
        let sectionFilter = filterViewModel.commonFilters.filter { !$0.needHide }[path.section]
        
        guard let type = sectionFilter.sectionType else { return CGSize.zero }
        switch type{
        case .singleChoice,
             .strongSingleChoice,
             .multipleChoice:
            
            return CGSize(width: (filterCollectionView.bounds.size.width - 24)/3, height: filterItemHeight)
            
            //            if let internalArray = sectionFilter.internalArray
            //            {
            ////                let config = internalArray.filter { !$0.needHide }[path.row]
            ////                let size = UIViewComHelper.realFontSize(UIFont.systemFontOfSize(13), title : config.value ,maxSize: CGSize(width: 200, height: filterItemHeight))
            ////
            ////
            //                return CGSize(width: (filterCollectionView.bounds.size.width - 24)/3, height: filterItemHeight)
            //            }
            //            else
            //            {
            //                return CGSizeZero
        //            }
        case .dialogChoice ,
             .singleDatePick,
             .inputText:
            return CGSize(width: self.filterCollectionView.bounds.size.width, height: filterItemHeight)
            
        case .durationDatePick :
            return CGSize(width: self.filterCollectionView.bounds.size.width, height: 35)
        case .slider :
            return CGSize(width: self.filterCollectionView.bounds.size.width, height: 80)
        default:
            return CGSize.zero
        }
    }
    
    /// 获取对应Cell
    ///
    /// - Parameter path: indexPath
    /// - Returns: cell
    fileprivate func cellForIndexPath(_ path : IndexPath) -> UICollectionViewCell
    {
        let sectionFilter = filterViewModel.commonFilters.filter { !$0.needHide }[path.section]
        
        guard let type = sectionFilter.sectionType else { return UICollectionViewCell() }
        switch type{
        case .singleChoice,
             .strongSingleChoice,
             .multipleChoice:
            if let internalArray = sectionFilter.internalArray
            {
                let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterSelectCell", for: path) as! FilterSelectCell
                let config = internalArray.filter { !$0.needHide }[path.row]
                cell.filterConfig = config
                
                return cell
            }
            else
            {
                return UICollectionViewCell()
            }
        case .inputText:
            
            let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterTextCell", for: path) as! FilterTextCell
            cell.filterSectionConfig = sectionFilter
            return cell
            
        case .dialogChoice:
            
            let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterDialogChoiceCell", for: path) as! FilterDialogChoiceCell
            
            cell.filterSectionConfig = sectionFilter
            
            return cell
            
        case .durationDatePick:
            let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterDurationCell", for: path) as! FilterDurationCell
            
            cell.filterSectionConfig = sectionFilter
            
            return cell
        case .slider:
            let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterSliderCell", for: path) as! FilterSliderCell
            
            cell.filterSectionConfig = sectionFilter
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    fileprivate func selectRowAtIndexPath(_ path : IndexPath)
    {
        let sectionFilter = filterViewModel.commonFilters.filter { !$0.needHide }[path.section]
        
        guard let type = sectionFilter.sectionType else { return }
        switch type{
        case .multipleChoice:
            if let internalArray = sectionFilter.internalArray
            {
                sectionFilter.isRunning = true
                let config = internalArray.filter { !$0.needHide }[path.row]
                config.isSelect = !config.isSelect
                
                var needPermission = false
                if let sectionPri = sectionFilter.conifgPriority, sectionPri >= currentPriority
                {
                    currentPriority = sectionPri
                    needPermission = true
                }
                
                //处理全选
                //当前选中的是全部
                if config.ignoreAll
                {
                    if config.isSelect
                    {
                        //反选所有其他的
                        internalArray.filter { !$0.needHide }.forEach({ (item) in
                            if item.value != config.value
                            {
                                item.isSelect = false
                            }
                        })
                        
                        //直接覆盖权限
                        if let conifgPer = config.conifgPermissions, needPermission
                        {
                            currentPermission = conifgPer
                        }
                    }
                }
                else
                {
                    //找出那个全选的并且将其反选
                    let allItem = internalArray.filter { !$0.needHide }.filter { $0.ignoreAll }.first
                    if let realAll = allItem
                    {
                        if realAll.isSelect && needPermission
                        {
                            //如果全部是选中的，则先删除原有权限
                            currentPermission.removeAll()
                        }
                        
                        realAll.isSelect = false
                    }
                    
                    //如果是反选，则移除权限
                    if !config.isSelect
                    {
                        if let permission = config.conifgPermissions, needPermission
                        {
                            permission.forEach({[weak self] (permis) in
                                guard let `self` = self else { return }
                                if let indexOfItem = self.currentPermission.index(of: permis), indexOfItem < self.currentPermission.count
                                {
                                    self.currentPermission.remove(at: indexOfItem)
                                }
                                })
                        }
                        
                        //如果木有选中了的，则删除权限
                        if let conifgs = sectionFilter.internalArray, needPermission
                        {
                            let selects = conifgs.filter { $0.isSelect }
                            
                            if selects.count == 0
                            {
                                self.currentPriority = 0
                            }
                        }
                    }
                    else
                    {
                        if let conifgPer = config.conifgPermissions, needPermission
                        {
                            currentPermission.append(contentsOf: conifgPer)
                        }
                        
                    }
                    
                    
                    if needPermission
                    {
                        permissionVerify()
                    }
                    
                }
                
            }
        case .singleChoice:
            if let internalArray = sectionFilter.internalArray
            {
                sectionFilter.isRunning = true
                let config = internalArray.filter { !$0.needHide }[path.row]
                guard !config.isSelect else {
   
                    
                    return
                }
                
                config.isSelect = !config.isSelect
                //如果是选中，则反选其他
                if config.isSelect
                {
                    internalArray.filter { !$0.needHide }.forEach({ (item) in
                        if item.value != config.value
                        {
                            item.isSelect = false
                        }
                    })
                    
                    if let sectionPri = sectionFilter.conifgPriority, sectionPri >= currentPriority
                    {
                        currentPriority = sectionPri
                        
                        if let conifgPer = config.conifgPermissions
                        {
                            currentPermission = conifgPer
                        }
                        permissionVerify()
                    }
                }
                
                guard let cell = filterCollectionView.cellForItem(at: path) as?FilterSelectCell else { return }
                
                cell.selectedStyle()
                
            }
        case .strongSingleChoice:
            if let internalArray = sectionFilter.internalArray
            {
                sectionFilter.isRunning = true
                let config = internalArray.filter { !$0.needHide }[path.row]
                guard !config.isSelect else {
                    
                    
                    return
                }
                
                config.isSelect = !config.isSelect
                //如果是选中，则反选其他
                if config.isSelect
                {
                    internalArray.filter { !$0.needHide }.forEach({ (item) in
                        if item.value != config.value
                        {
                            item.isSelect = false
                        }
                    })
                    
                    if let sectionPri = sectionFilter.conifgPriority, sectionPri >= currentPriority
                    {
                        currentPriority = sectionPri
                        
                        if let conifgPer = config.conifgPermissions
                        {
                            currentPermission = conifgPer
                        }
                        permissionVerify()
                    }
                }
                
                guard let cell = filterCollectionView.cellForItem(at: path) as?FilterSelectCell else { return }
                
                cell.selectedStyle()
                
            }
            
        default:
            return
        }
    }
    
    fileprivate func permissionVerify()
    {
        guard currentPriority != 0 && currentPermission.count != 0 else { return }
        
        for section in filterViewModel.commonFilters
        {
            //先重置权限
            section.needHide = false
            
            if let inters = section.internalArray
            {
                inters.forEach({ (model) in
                    model.needHide = false
                })
            }
            
            //如果section的priority小于当前，则继续
            guard let sectionPro = section.conifgPriority else { continue }
            
            guard sectionPro < currentPriority else { continue }
            
            //如果section有权限，则直接无视内部，以section权限为准
            
            if let sectionPer = section.conifgPermissions
            {
                section.needHide = !isPerssionContained(sectionPer, father: currentPermission)
            }
                
                //如果section无权限，则看limian
            else
            {
                if let internals = section.internalArray
                {
                    //判断每个section权限
                    var needAllSelectRefresh = false
                    internals.forEach({[weak self] (model) in
                        guard let `self` = self else { return }
                        if let permmisions = model.conifgPermissions
                        {
                            //获取权限是否符合
                            //判断与原本权限是否有差别
                            let permission = !self.isPerssionContained(permmisions, father: self.currentPermission)
                            
                            if permission != model.needHide
                            {
                                needAllSelectRefresh = true
                            }
                            
                            model.needHide = !self.isPerssionContained(permmisions, father: self.currentPermission)
                        }
                        })
                    
                    //如果有差，则刷新整个internal的select
                    if needAllSelectRefresh
                    {
                        internals.forEach({ (model) in
                            if model.value == "全部"
                            {
                                model.isSelect = true
                            }
                            else
                            {
                                model.isSelect = false
                            }
                            
                        })
                    }
                }
            }
            
        }
        
        guard let filterCollection = filterCollectionView else { return }
        filterCollection.reloadData()
    }
    
    fileprivate func isPerssionContained(_ son : [Int] , father : [Int]) -> Bool
    {
        var isContained = false
        son.forEach({ (per) in
            isContained = father.contains(per)
            if isContained
            {
                return
            }
        })
        
        return isContained
    }
}

// MARK: - Archived configs

extension CommonFilterController {
    
    fileprivate func loadFilterConfigs() -> [String: Any]? {
        if let path = configArchivePathURL()?.path {
            return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String: Any]
        }
        
        return nil
    }
    
    @discardableResult
    fileprivate func archiveFilterConfigs(_ configs: [String: Any]) -> Bool {
        if let path = configArchivePathURL()?.path {
            return NSKeyedArchiver.archiveRootObject(configs, toFile: path)
        }
        
        return false
    }
    
    fileprivate func configArchivePathURL() -> URL? {
        guard let archiveKey = self.archiveKey else {
            return nil
        }
        
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentDirectory = documentDirectories.first {
            var url = URL(string: documentDirectory)!
            url.appendPathComponent("\(Bundle.main.bundleIdentifier!).\(User.currentUser.userId.intValue).\(archiveKey).data")
            return url
        }
        
        return nil
    }
}

