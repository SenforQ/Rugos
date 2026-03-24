
//: Declare String Begin

/*: "mf/recharge/createApplePay" :*/
fileprivate let main_pickUpMessage:String = "safe need activity acrossmf/re"
fileprivate let deviceSelectData:String = "engine later script transaction sharedge/c"
fileprivate let engineBuildHandToken:String = "pplePareport hide ok"
fileprivate let user_fullPath:String = "Y"

/*: "productId" :*/
fileprivate let cacheMinuteOriginValue:[Character] = ["p","r","o","d","u","c"]
fileprivate let formatterGraduatedTableFormat:String = "tIdreplace and"

/*: "source" :*/
fileprivate let userFullMessage:[Character] = ["s","o","u","r","c","e"]

/*: "orderNum" :*/
fileprivate let logBackFatalName:String = "otablede"

/*: "mf/recharge/applePayNotify" :*/
fileprivate let const_userFlag:String = "since readingmf/rec"
fileprivate let configAtValue:String = "/appledevice type key in failure"

/*: "reportMoney" :*/
fileprivate let data_quantitativeRelationList:String = "rcancelpo"

/*: "transactionId" :*/
fileprivate let parserFailureStatus:[Character] = ["t","r","a","n","s","a","c","t","i","o","n","I","d"]

/*: "mf/AutoSub/AppleCreateOrder" :*/
fileprivate let networkElementUrl:[Character] = ["m","f","/","A","u","t","o","S","u","b","/","A","p","p","l","e","C","r","e"]
fileprivate let succeedBirdValue:[Character] = ["a","t","e","O","r","d","e","r"]

/*: "orderId" :*/
fileprivate let cacheHeadState:[UInt8] = [0x82,0x9f,0x89,0x88,0x9f,0xa4,0x89]

private func canNeed(cancel num: UInt8) -> UInt8 {
    return num ^ 237
}

/*: "mf/AutoSub/ApplePaySuccess" :*/
fileprivate let routerPicSecret:[Character] = ["m","f","/","A","u","t","o","S","u"]
fileprivate let cacheUpURL:String = "table"
fileprivate let loggerPracticalApplicationMessage:String = "raw load/Apple"
fileprivate let parserReplaceID:String = "ccefull"

/*: "App" :*/
fileprivate let loggerLevelPath:[Character] = ["A","p","p"]

/*: "OrderTransactionInfo_Cache" :*/
fileprivate let viewFormMode:String = "pad"
fileprivate let show_birdToken:[Character] = ["r","d","e","r","T","r","a","n","s","a","c","t","i","o","n","I","n","f","o","_","C","a","c","h","e"]

/*: "OrderTransactionInfo_Subscribe_Cache" :*/
fileprivate let show_forwardDict:[UInt8] = [0xbc,0x81,0x97,0x96,0x81,0xa7,0x81,0x92,0x9d,0x80,0x92,0x90,0x87,0x9a,0x9c,0x9d,0xba,0x9d,0x95,0x9c,0xac,0xa0,0x86,0x91,0x80,0x90,0x81,0x9a,0x91,0x96,0xac,0xb0,0x92,0x90,0x9b,0x96]

private func nameShared(grant num: UInt8) -> UInt8 {
    return num ^ 243
}

/*: "verifyData" :*/
fileprivate let user_tunState:[UInt8] = [0x38,0x27,0x34,0x2b,0x28,0x3b,0x6,0x23,0x36,0x23]

fileprivate func pullUpShort(component num: UInt8) -> UInt8 {
    let value = Int(num) + 62
    if value > 255 {
        return UInt8(value - 256)
    } else {
        return UInt8(value)
    }
}

/*: " 未知的交易类型" :*/
fileprivate let controllerMinuteFirstID:String = " 未知"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit
//: import StoreKit
import StoreKit
 
// 最大失败重试次数
//: let APPLE_IAP_MAX_RETRY_COUNT = 9
let mainSalesDict = 9

/// 支付类型
//: enum ApplePayType {
enum PrivacyVersionBar {
    //: case Pay        
    case Pay        // 支付
    //: case Subscribe  
    case Subscribe  // 订阅
}
/// 支付状态
//: enum AppleIAPStatus: String {
enum LoadFatal: String {
    //: case unknow            = "未知类型"
    case unknow            = "未知类型"
    //: case createOrderFail   = "创建订单失败"
    case createOrderFail   = "创建订单失败"
    //: case notArrow          = "设备不允许"
    case notArrow          = "设备不允许"
    //: case noProductId       = "缺少产品Id"
    case noProductId       = "缺少产品Id"
    //: case failed            = "交易失败/取消"
    case failed            = "交易失败/取消"
    //: case restored          = "已购买过该商品"
    case restored          = "已购买过该商品"
    //: case deferred          = "交易延期"
    case deferred          = "交易延期"
    //: case verityFail        = "服务器验证失败"
    case verityFail        = "服务器验证失败"
    //: case veritySucceed     = "服务器验证成功"
    case veritySucceed     = "服务器验证成功"
    //: case renewSucceed      = "自动续订成功"
    case renewSucceed      = "自动续订成功"
}

//: typealias IAPcompletionHandle = (AppleIAPStatus, Double, ApplePayType) -> Void
typealias IAPcompletionHandle = (LoadFatal, Double, PrivacyVersionBar) -> Void

//: class AppleIAPManager: NSObject {
class OfCharacter: NSObject {
    
    //: var completionHandle: IAPcompletionHandle?
    var completionHandle: IAPcompletionHandle?
    //: private var productInfoReq: SKProductsRequest?
    private var productInfoReq: SKProductsRequest?
    //: private var reqRetryCountDict = [String: Int]()         
    private var reqRetryCountDict = [String: Int]()         // 记录每个交易请求重试次数
    //: private var payCacheList = [[String: String]]()         
    private var payCacheList = [[String: String]]()         // 【购买】缓存数据
    //: private var subscribeCacheList = [[String: String]]()   
    private var subscribeCacheList = [[String: String]]()   // 【订阅】缓存数据
    //: private var createOrderId: String?                      
    private var createOrderId: String?                      // 当前支付服务端创建的订单id
    //: private var currentPayType: ApplePayType = .Pay         
    private var currentPayType: PrivacyVersionBar = .Pay         // 当前支付类型
    
    // singleton
    //: static let shared = AppleIAPManager()
    static let shared = OfCharacter()
    //: override func copy() -> Any { return self }
    override func copy() -> Any { return self }
    //: override func mutableCopy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    //: private override init() {
    private override init() {
        //: super.init()
        super.init()
        //: SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        // 监听应用将要销毁
        //: NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate),
        NotificationCenter.default.addObserver(self, selector: #selector(error),
                                               //: name: UIApplication.willTerminateNotification,
                                               name: UIApplication.willTerminateNotification,
                                               //: object: nil)
                                               object: nil)
    }

    // MARK: - NotificationCenter
    //: @objc func appWillTerminate() {
    @objc func error() {
        //: SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

// MARK: - 【苹果购买】业务接口
//: extension AppleIAPManager {
extension OfCharacter {
    /// 【购买】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_pay_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    fileprivate func fileScript(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = DeviceModel.init()
        //: reqModel.requestPath = "mf/recharge/createApplePay"
        reqModel.requestPath = (String(main_pickUpMessage.suffix(5)) + "char" + String(deviceSelectData.suffix(4)) + "reateA" + String(engineBuildHandToken.prefix(6)) + user_fullPath.lowercased())
        //: var dict = Dictionary<String, Any>()
        var dict = Dictionary<String, Any>()
        //: dict["productId"] = productId
        dict[(String(cacheMinuteOriginValue) + String(formatterGraduatedTableFormat.prefix(3)))] = productId
        //: dict["source"] = source
        dict[(String(userFullMessage))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        StuffTrigger.bridgeAfter(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String?
            var orderId: String?
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderNum"] as? String {
            if let value = dict?[(logBackFatalName.replacingOccurrences(of: "table", with: "r") + "rNum")] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }
    
    /// 【购买】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_pay_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    fileprivate func decision(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = DeviceModel.init()
        //: reqModel.requestPath = "mf/recharge/applePayNotify"
        reqModel.requestPath = (String(const_userFlag.suffix(6)) + "harge" + String(configAtValue.prefix(6)) + "PayNotify")
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        StuffTrigger.bridgeAfter(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else { 
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    //: self.transcationPurchasedToCheck(transactionId, .Pay)
                    self.totalUp(transactionId, .Pay)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(data_quantitativeRelationList.replacingOccurrences(of: "cancel", with: "e") + "rtMoney")] as? Double { return d }
                //: return 0
                return 0
            //: }()
            }()
            
            // 过滤已验证成功的订单数据
            //: let newPayCacheList = self.payCacheList.filter({$0["transactionId"] != transactionId})
            let newPayCacheList = self.payCacheList.filter({$0[(String(parserFailureStatus))] != transactionId})
            //: let diskPath = self.getPayCachePath()
            let diskPath = self.evaluateDoingce()
            //: NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
                        
            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Pay)
            self.completionHandle?(.veritySucceed, reportMoney, .Pay)
        }
    }
}

// MARK: - 【苹果订阅】业务接口
//: extension AppleIAPManager {
extension OfCharacter {
    /// 【订阅】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_subscribe_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    fileprivate func centerClear(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = DeviceModel.init()
        //: reqModel.requestPath = "mf/AutoSub/AppleCreateOrder"
        reqModel.requestPath = (String(networkElementUrl) + String(succeedBirdValue))
        //: var dict = Dictionary<String, Any>()
        var dict = Dictionary<String, Any>()
        //: dict["productId"] = productId
        dict[(String(cacheMinuteOriginValue) + String(formatterGraduatedTableFormat.prefix(3)))] = productId
        //: dict["source"] = source
        dict[(String(userFullMessage))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        StuffTrigger.bridgeAfter(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String? = nil
            var orderId: String? = nil
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderId"] as? String {
            if let value = dict?[String(bytes: cacheHeadState.map{canNeed(cancel: $0)}, encoding: .utf8)!] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }
    
    /// 【订阅】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_subscribe_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    fileprivate func confirm(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = DeviceModel.init()
        //: reqModel.requestPath = "mf/AutoSub/ApplePaySuccess"
        reqModel.requestPath = (String(routerPicSecret) + cacheUpURL.replacingOccurrences(of: "table", with: "b") + String(loggerPracticalApplicationMessage.suffix(6)) + "PaySu" + parserReplaceID.replacingOccurrences(of: "full", with: "ss"))
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        StuffTrigger.bridgeAfter(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else { 
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    //: self.transcationPurchasedToCheck(transactionId, .Subscribe)
                    self.totalUp(transactionId, .Subscribe)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(data_quantitativeRelationList.replacingOccurrences(of: "cancel", with: "e") + "rtMoney")] as? Double { return d }
                //: return 0
                return 0
            //: }()
            }()

            // 过滤已验证成功的订单数据
            //: let newSubscribeCacheList = self.subscribeCacheList.filter({$0["transactionId"] != transactionId})
            let newSubscribeCacheList = self.subscribeCacheList.filter({$0[(String(parserFailureStatus))] != transactionId})
            //: let diskPath = self.getSubscribeCachePath()
            let diskPath = self.sizeHead()
            //: NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
 
            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
            self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
        }
    }
}

// MARK: - Event
//: extension AppleIAPManager {
extension OfCharacter {
    /// 初始化数据
    //: private func iap_initData() {
    private func pastPath() {
        //: self.payCacheList = getLocalPayCacheList(payType: .Pay)
        self.payCacheList = waitWith(payType: .Pay)
        //: self.subscribeCacheList = getLocalPayCacheList(payType: .Subscribe)
        self.subscribeCacheList = waitWith(payType: .Subscribe)
        //: self.createOrderId = nil
        self.createOrderId = nil
    }
    
    /// 获取缓存列表
    /// - Parameter payType: 支付类型
    /// - Returns: 缓存列表
    //: private func getLocalPayCacheList(payType: ApplePayType) -> [[String: String]] {
    private func waitWith(payType: PrivacyVersionBar) -> [[String: String]] {
        //: var list: [[String: String]]?
        var list: [[String: String]]?
        //: var diskPath = ""
        var diskPath = ""
        //: if payType == .Pay {
        if payType == .Pay {
            //: diskPath = getPayCachePath()
            diskPath = evaluateDoingce()
        //: } else {
        } else {
            //: diskPath = getSubscribeCachePath()
            diskPath = sizeHead()
        }
        
        //: if FileManager.default.fileExists(atPath: diskPath) {
        if FileManager.default.fileExists(atPath: diskPath) {
            //: list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            //: if list == nil {
            if list == nil {
               //: try? FileManager.default.removeItem(atPath: diskPath)
               try? FileManager.default.removeItem(atPath: diskPath)
            }
        }
        //: if list == nil {
        if list == nil {
            //: list = [[String: String]]()
            list = [[String: String]]()
        }
        //: return list!
        return list!
    }
    
    /// 获取【购买】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getPayCachePath() -> String {
    private func evaluateDoingce() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(loggerLevelPath)))
        
        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent((viewFormMode.replacingOccurrences(of: "pad", with: "O") + String(show_birdToken)))
        //: return filePath
        return filePath
    }
    
    /// 获取【订阅】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getSubscribeCachePath() -> String {
    private func sizeHead() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(loggerLevelPath)))
        
        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Subscribe_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent(String(bytes: show_forwardDict.map{nameShared(grant: $0)}, encoding: .utf8)!)
        //: return filePath
        return filePath
    }
 
    /// 获取本地收据数据
    /// - Parameters:
    ///   - transactionId: 收据标识符
    ///   - payType: 支付类型
    /// - Returns: 收据数据
    //: fileprivate func getVerifyData(_ transactionId: String, _ payType: ApplePayType) -> String? {
    fileprivate func root(_ transactionId: String, _ payType: PrivacyVersionBar) -> String? {
        // 有未完成的订单，先取缓存
        //: var paramsArr = [[String: String]]()
        var paramsArr = [[String: String]]()
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.payCacheList.filter({$0[(String(parserFailureStatus))] == transactionId})
        //: case .Subscribe:
        case .Subscribe:
            //: paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.subscribeCacheList.filter({$0[(String(parserFailureStatus))] == transactionId})
        }
        //: if paramsArr.count > 0 && paramsArr.first!["verifyData"] != nil {
        if paramsArr.count > 0 && paramsArr.first![String(bytes: user_tunState.map{pullUpShort(component: $0)}, encoding: .utf8)!] != nil {
            //: return paramsArr.first!["verifyData"]
            return paramsArr.first![String(bytes: user_tunState.map{pullUpShort(component: $0)}, encoding: .utf8)!]
        }

        // 取本地
        //: guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        //: let data = NSData(contentsOf: receiptUrl)
        let data = NSData(contentsOf: receiptUrl)
        //: let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //: return receiptStr
        return receiptStr
    }
}

// MARK: - 失败重试流程
//: extension AppleIAPManager {
extension OfCharacter {
    /// 检测未完成的苹果支付【只会重试当前登录用户】
    //: func iap_checkUnfinishedTransactions() {
    func camera() {
        //: iap_initData()
        pastPath()

        // 【购买】失败重试
        //: for dict in self.payCacheList {
        for dict in self.payCacheList {
            //: iap_failedRetry(dict["transactionId"], .Pay)
            cancel(dict[(String(parserFailureStatus))], .Pay)
        }
        
        // 【订阅】失败重试
        //: for dict in self.subscribeCacheList {
        for dict in self.subscribeCacheList {
            //: iap_failedRetry(dict["transactionId"], .Subscribe)
            cancel(dict[(String(parserFailureStatus))], .Subscribe)
        }
    }
    
    /// 失败重试
    /// - Parameters:
    ///   - transactionId: Id
    ///   - payType: 支付类型
    //: private func iap_failedRetry(_ transactionId: String?, _ payType: ApplePayType) {
    private func cancel(_ transactionId: String?, _ payType: PrivacyVersionBar) {
        //: guard let transactionId = transactionId else { return }
        guard let transactionId = transactionId else { return }
        // 初始化每个交易请求次数
        //: reqRetryCountDict[transactionId] = 0
        reqRetryCountDict[transactionId] = 0
        // 3. 服务端校验流程
        //: transcationPurchasedToCheck(transactionId, payType)
        totalUp(transactionId, payType)
    }
}

// MARK: - 苹果正常支付流程
//: extension AppleIAPManager {
extension OfCharacter {
    /// 发起苹果支付【1.创建订单； 2.发起苹果支付； 3.服务端校验】
    /// - Parameters:
    ///   - purchID: 产品ID
    ///   - payType: 支付类型
    ///   - handle: 回调
    ///   - source: 0 常规充值 1 观看视频后充值或订阅
    //: func iap_startPurchase(productId: String, payType: ApplePayType, source: Int = 0, handle: @escaping IAPcompletionHandle) {
    func handle(productId: String, payType: PrivacyVersionBar, source: Int = 0, handle: @escaping IAPcompletionHandle) {
        //: iap_initData()
        pastPath()
        //: self.completionHandle = handle
        self.completionHandle = handle
        //: self.currentPayType = payType
        self.currentPayType = payType
        
        // 1. 根据类型创建订单
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: req_pay_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            fileScript(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else { 
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Pay)
                    self.completionHandle?(.createOrderFail, 0, .Pay)
                    //: return
                    return
                }
                
                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.after(productId)
            }
        
        //: case .Subscribe:
        case .Subscribe:
            //: req_subscribe_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            centerClear(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else { 
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    //: return
                    return
                }
                
                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.after(productId)
            }
        }
    }
        
    // 2 发起苹果支付，查询apple内购商品
    //: fileprivate func requestProductInfo(_ productId: String) {
    fileprivate func after(_ productId: String) {
        //: guard SKPaymentQueue.canMakePayments() else {
        guard SKPaymentQueue.canMakePayments() else {
            //: self.completionHandle?(.notArrow, 0, currentPayType)
            self.completionHandle?(.notArrow, 0, currentPayType)
            //: return
            return
        }
        
        // 销毁当前请求
        //: self.clearProductInfoRequest()
        self.go()
        // 查询apple内购商品
        //: let identifiers: Set<String> = [productId]
        let identifiers: Set<String> = [productId]
        //: productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        //: productInfoReq?.delegate = self
        productInfoReq?.delegate = self
        //: productInfoReq?.start()
        productInfoReq?.start()
    }
    
    // 销毁当前请求
    //: fileprivate func clearProductInfoRequest() {
    fileprivate func go() {
        //: guard productInfoReq != nil else { return }
        guard productInfoReq != nil else { return }
        //: productInfoReq?.delegate = nil
        productInfoReq?.delegate = nil
        //: productInfoReq?.cancel()
        productInfoReq?.cancel()
        //: productInfoReq = nil
        productInfoReq = nil
    }
}

// MARK: - SKProductsRequestDelegate【商品查询】
//: extension AppleIAPManager: SKProductsRequestDelegate {
extension OfCharacter: SKProductsRequestDelegate {
    // 查询apple内购商品成功回调
     //: func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
         //: guard response.products.count > 0 else {
         guard response.products.count > 0 else {
             //: self.completionHandle?( .noProductId, 0, currentPayType)
             self.completionHandle?( .noProductId, 0, currentPayType)
             //: return
             return
         }
         
         //: let payment = SKPayment(product: response.products.first!)
         let payment = SKPayment(product: response.products.first!)
         //: SKPaymentQueue.default().add(payment)
         SKPaymentQueue.default().add(payment)
     }
    
    // 查询apple内购商品失败
    //: func request(_ request: SKRequest, didFailWithError error: Error) {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        //: self.completionHandle?( .noProductId, 0, currentPayType)
        self.completionHandle?( .noProductId, 0, currentPayType)
    }
    
    // 查询apple内购商品完成
    //: func requestDidFinish(_ request: SKRequest) {
    func requestDidFinish(_ request: SKRequest) {
        
    }
}

// MARK: - SKPaymentTransactionObserver【支付回调】
//: extension AppleIAPManager: SKPaymentTransactionObserver {
extension OfCharacter: SKPaymentTransactionObserver {
    /// 2.2 apple内购完成回调
    //: func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //: for transaction in transactions {
        for transaction in transactions {
            //: switch transaction.transactionState {
            switch transaction.transactionState {
            //: case .purchasing:  
            case .purchasing:  // 交易中
                //: break
                break
                
            //: case .purchased:   
            case .purchased:   // 交易成功
                /**
                 original.transactionIdentifier 首次订阅时为nil，transaction.transactionIdentifier有值；
                 后续自动订阅、续订时，original.transactionIdentifier为首次订阅时生成的transaction.transactionIdentifier，值固定不变；
                 每次订阅transaction.transactionIdentifier都不一样，为当前交易的标识；
                 */
                //: if transaction.original != nil && createOrderId == nil { 
                if transaction.original != nil && createOrderId == nil { // 启动自动续订时，不需要调用服务端验证接口
                    //: self.completionHandle?(.renewSucceed, 0, currentPayType)
                    self.completionHandle?(.renewSucceed, 0, currentPayType)
                //: } else { 
                } else { // 普通购买和订阅
                    // 初始化每个交易请求次数
                    //: reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    // 3. 服务端校验流程
                    //: transcationPurchasedToCheck(transaction.transactionIdentifier!, self.currentPayType)
                    totalUp(transaction.transactionIdentifier!, self.currentPayType)
                }
                // 移除苹果支付系统缓存
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: createOrderId = nil
                createOrderId = nil
                
            //: case .failed:      
            case .failed:      // 交易失败/取消
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.failed, 0, currentPayType)
                self.completionHandle?(.failed, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil

            //: case .restored:    
            case .restored:    // 已购买过该商品
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.restored, 0, currentPayType)
                self.completionHandle?(.restored, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                
            //: case .deferred:    
            case .deferred:    // 交易延期
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.deferred, 0, currentPayType)
                self.completionHandle?(.deferred, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                
            //: @unknown default:
            @unknown default:
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.unknow, 0, currentPayType)
                self.completionHandle?(.unknow, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                //: fatalError(" 未知的交易类型")
                fatalError((controllerMinuteFirstID.capitalized + "的交\u{6613}类型"))
            }
        }
    }
 
    /// 3. 服务端校验流程
    /// - Parameters:
    ///   - transactionId: 交易唯一标识符
    ///   - payType: 支付类型
    //: fileprivate func transcationPurchasedToCheck(_ transactionId: String, _ payType: ApplePayType) {
    fileprivate func totalUp(_ transactionId: String, _ payType: PrivacyVersionBar) {
        //: guard let receiptStr = getVerifyData(transactionId, payType) else {
        guard let receiptStr = root(transactionId, payType) else {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }

        // 缓存支付成功信息，防止接口校验失败
        //: if createOrderId != nil { 
        if createOrderId != nil { // 正常支付流程
            //: switch(payType) {
            switch(payType) {
            //: case .Pay:
            case .Pay:
                //: if self.payCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                if self.payCacheList.filter({$0[(String(parserFailureStatus))] == transactionId || $0[String(bytes: cacheHeadState.map{canNeed(cancel: $0)}, encoding: .utf8)!] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(String(parserFailureStatus)): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: cacheHeadState.map{canNeed(cancel: $0)}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: user_tunState.map{pullUpShort(component: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.payCacheList.append(cacheDict)
                    self.payCacheList.append(cacheDict)
                    //: let diskPath = self.getPayCachePath()
                    let diskPath = self.evaluateDoingce()
                    //: NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                }
                
            //: case .Subscribe:
            case .Subscribe:
                //: if self.subscribeCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                if self.subscribeCacheList.filter({$0[(String(parserFailureStatus))] == transactionId || $0[String(bytes: cacheHeadState.map{canNeed(cancel: $0)}, encoding: .utf8)!] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(String(parserFailureStatus)): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: cacheHeadState.map{canNeed(cancel: $0)}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: user_tunState.map{pullUpShort(component: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.subscribeCacheList.append(cacheDict)
                    self.subscribeCacheList.append(cacheDict)
                    //: let diskPath = self.getSubscribeCachePath()
                    let diskPath = self.sizeHead()
                    //: NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                }
            }
        }
        
        // 限制交易重试最大次数
        //: var reqCount = reqRetryCountDict[transactionId] ?? 0
        var reqCount = reqRetryCountDict[transactionId] ?? 0
        //: reqCount += 1
        reqCount += 1
        //: reqRetryCountDict[transactionId] = reqCount
        reqRetryCountDict[transactionId] = reqCount
        //: if reqCount > APPLE_IAP_MAX_RETRY_COUNT {
        if reqCount > mainSalesDict {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }
        
        // 3.服务端校验，根据transactionId从缓存中取
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: let paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.payCacheList.filter({$0[(String(parserFailureStatus))] == transactionId})
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_pay_uploadAppletransaction(transactionId, params: paramsArr.first!)
            decision(transactionId, params: paramsArr.first!)
            
        //: case .Subscribe:
        case .Subscribe:
            //: let paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.subscribeCacheList.filter({$0[(String(parserFailureStatus))] == transactionId})
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_subscribe_uploadAppletransaction(transactionId, params: paramsArr.first!)
            confirm(transactionId, params: paramsArr.first!)
        }
    }
}