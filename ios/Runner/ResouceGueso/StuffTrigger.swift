
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let showProductionFormat:String = "on kind filterNet E"
fileprivate let engineOfPageKey:[Character] = [","," ","T","r","y"," ","a","g","a","i","n"," ","l","a","t","e","r"]

/*: "data" :*/
fileprivate let managerScreenEnterKey:String = "DATA"

/*: ":null" :*/
fileprivate let factoryCenterString:[Character] = [":","n","u","l","l"]

/*: "json error" :*/
fileprivate let loggerTotalervalReValue:String = "jsminute"
fileprivate let notiSkinColourId:String = "since network valid revenuen error"

/*: "platform=iphone&version= :*/
fileprivate let helperWholeMessage:[Character] = ["p","l","a","t","f","o","r","m","=","i"]
fileprivate let configPanelKey:[Character] = ["p","h","o","n"]
fileprivate let dataAccessPath:[Character] = ["e","&","v","e","r","s","i","o","n","="]

/*: &packageId= :*/
fileprivate let routerPrivacySecret:String = "case bridge device prompt&pa"
fileprivate let formatterEraseEvaluateError:[Character] = ["c","k","a","g","e","I","d","="]

/*: &bundleId= :*/
fileprivate let showLabURL:String = "&buncan trust local please powder"

/*: &lang= :*/
fileprivate let modelSecretSourceTingCount:String = "&lang=contact disappear"

/*: ; build: :*/
fileprivate let appTopFullName:String = "full category as time evaluate; build:"

/*: ; iOS  :*/
fileprivate let noti_infoName:[Character] = [";"," ","i","O","S"," "]

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit
//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
 
//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: ElectronicDatabaseActive?) -> Void
 
//: @objc class AppRequestTool: NSObject {
@objc class StuffTrigger: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func bridgeAfter(model: DeviceModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.sharedEnablece(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.insideTrack(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                permission(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                
            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, ElectronicDatabaseActive.init(errorCode: ManagerSucceed.NetError.rawValue, errorMsg: (String(showProductionFormat.suffix(5)) + "rror" + String(engineOfPageKey))))
            }
        }
    }
    
    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func permission(model: DeviceModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (managerScreenEnterKey.lowercased()) + "\"" + (String(factoryCenterString)), with: "" + "\"" + (managerScreenEnterKey.lowercased()) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<DataProviderWithout>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == ManagerSucceed.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
            //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, ElectronicDatabaseActive.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case ManagerSucceed.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
        //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, ElectronicDatabaseActive.init(errorCode: ManagerSucceed.NetError.rawValue, errorMsg: (loggerTotalervalReValue.replacingOccurrences(of: "minute", with: "o") + String(notiSkinColourId.suffix(7)))))
        }
                
    }
    
    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func sharedEnablece(model: DeviceModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (String(helperWholeMessage) + String(configPanelKey) + String(dataAccessPath)) + "\(engineWarnZoneMsg)" + (String(routerPrivacySecret.suffix(3)) + String(formatterEraseEvaluateError)) + "\(parserNetMessage)" + (String(showLabURL.prefix(4)) + "dleId=") + "\(controllerNumberFormat)" + (String(modelSecretSourceTingCount.prefix(6))) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")
        
        //: return serverUrl
        return serverUrl
    }
    
    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func insideTrack(model: DeviceModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(cacheWarnVersionURL)/\(networkTotalervalData) (\(controllerNumberFormat)" + (String(appTopFullName.suffix(8))) + "\(mainEnvironmentUrl)" + (String(noti_infoName)) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
 