
//: Declare String Begin

/*: "socoay" :*/
fileprivate let cacheFieldPointSecret:[Character] = ["s"]
fileprivate let parserPoorSecretFlag:String = "ocoaversion"

/*: "920" :*/
fileprivate let loggerEventNetKey:String = "920"

/*: "lpn1ppwofrpc" :*/
fileprivate let loggerMediaValue:String = "lpnbehaviorpwo"
fileprivate let constSuccessFactoryDict:String = "frpsince"

/*: "slvx4i" :*/
fileprivate let sessionScreenFormat:String = "slvclosei"

/*: "1.9.1" :*/
fileprivate let controllerTrustAppearSecret:[Character] = ["1",".","9",".","1"]

/*: "https://m. :*/
fileprivate let modelImageURL:[Character] = ["h","t","t","p","s",":","/","/"]
fileprivate let mainContextValue:String = "m.mirror global copy"

/*: .com" :*/
fileprivate let parserStartCount:String = "deadline grant response appear language.com"

/*: "CFBundleShortVersionString" :*/
fileprivate let showCountString:String = "CFBunwill float reduce"
fileprivate let dataFlexibleUrl:String = "tVersitransform trust tool time"
fileprivate let const_putUpListId:String = "contrast powder arrow textonString"

/*: "CFBundleDisplayName" :*/
fileprivate let data_agentStopName:String = "white titleCFBundleD"
fileprivate let show_processBuildMode:[Character] = ["i","s","p","l","a","y","N","a","m","e"]

/*: "CFBundleVersion" :*/
fileprivate let routerNameCount:String = "any main disappearCFBund"
fileprivate let configDecidePath:String = "rbehaviorion"

/*: "en" :*/
fileprivate let kHandDate:String = "EN"

/*: "weixin" :*/
fileprivate let startMessagePath:String = "weitoolin"

/*: "wxwork" :*/
fileprivate let serviceControlError:[Character] = ["w","x","w","o","r","k"]

/*: "dingtalk" :*/
fileprivate let viewAtURL:String = "dregionngtalk"

/*: "lark" :*/
fileprivate let notiScriptVersion:String = "lbridgerk"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  PhoneAdapt.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "socoay"
let mainGoCount = (String(cacheFieldPointSecret) + parserPoorSecretFlag.replacingOccurrences(of: "version", with: "y"))
/// 包ID
//: let PackageID = "920"
let parserNetMessage = (loggerEventNetKey.replacingOccurrences(of: "dismiss", with: "92"))
/// Adjust
//: let AdjustKey = "lpn1ppwofrpc"
let serviceNowadaysCombineCount = (loggerMediaValue.replacingOccurrences(of: "behavior", with: "1p") + constSuccessFactoryDict.replacingOccurrences(of: "since", with: "c"))
//: let AdInstallToken = "slvx4i"
let sessionTimeModeSecret = (sessionScreenFormat.replacingOccurrences(of: "close", with: "x4"))

/// 网络版本号
//: let AppNetVersion = "1.9.1"
let engineWarnZoneMsg = (String(controllerTrustAppearSecret))
//: let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let factoryMinBuildResult = (String(modelImageURL) + String(mainContextValue.prefix(2))) + "\(mainGoCount)" + (String(parserStartCount.suffix(4)))
//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let networkTotalervalData = Bundle.main.infoDictionary![(String(showCountString.prefix(5)) + "dleShor" + String(dataFlexibleUrl.prefix(6)) + String(const_putUpListId.suffix(8)))] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let controllerNumberFormat = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let cacheWarnVersionURL = Bundle.main.infoDictionary![(String(data_agentStopName.suffix(9)) + String(show_processBuildMode))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let mainEnvironmentUrl = Bundle.main.infoDictionary![(String(routerNameCount.suffix(6)) + "leVe" + configDecidePath.replacingOccurrences(of: "behavior", with: "s"))] as! String

//: class AppConfig: NSObject {
class PhoneAdapt: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func takeAPowder() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
        //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func decideOf() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
        //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func purchase() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = PhoneAdapt.decideOf()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return birdSEyeViewPhoto(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func birdSEyeViewPhoto(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return birdSEyeViewPhoto(presentVC)
        //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return birdSEyeViewPhoto(selectVC)
            }
            //: return nil
            return nil
        //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return birdSEyeViewPhoto(naiVC.visibleViewController)
        //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device
//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.centerFinish()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return (kHandDate.lowercased())
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(serviceNowadaysCombineCount) {
            //: return value
            return value
        //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: serviceNowadaysCombineCount)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.at((startMessagePath.replacingOccurrences(of: "tool", with: "x"))) {
            //: appsArr.append("weixin")
            appsArr.append((startMessagePath.replacingOccurrences(of: "tool", with: "x")))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.at((String(serviceControlError))) {
            //: appsArr.append("wxwork")
            appsArr.append((String(serviceControlError)))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.at((viewAtURL.replacingOccurrences(of: "region", with: "i"))) {
            //: appsArr.append("dingtalk")
            appsArr.append((viewAtURL.replacingOccurrences(of: "region", with: "i")))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.at((notiScriptVersion.replacingOccurrences(of: "bridge", with: "a"))) {
            //: appsArr.append("lark")
            appsArr.append((notiScriptVersion.replacingOccurrences(of: "bridge", with: "a")))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func at(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func centerFinish() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? (kHandDate.lowercased())
    }
}
