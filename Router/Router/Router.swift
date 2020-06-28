//
//  Router.swift
//  Router
//
//  Created by caoye on 2020/5/26.
//  Copyright © 2020 caoye. All rights reserved.
//

import UIKit

//注册的key
let routerKey: String = "router";
let classKey:  String = "controllerClass";
let blockKey:  String = "block";

//调用的key
let rouderToVcKey:     String = "rouderToVcKey";
let rouderFromVcKey:   String = "rouderFromVcKey";
let routerNavKey:      String = "routerNavKey";
let routerTypeKey:     String = "routerTypeKey";
let routerAnimatedKey: String = "routerAnimatedKey";
let routerClassKey:    String = "routerClassKey";


let routerCompletionKey: String = "routerHandlerKey";
let backBlockKey:     String = "backBlockKey";

enum RouterJumpType: NSInteger {
    case push    = 1
    case present = 2
    case pop     = 3
    case popRoot = 4
    case popSome = 5
    case dismiss = 6
}


enum CallBackType: NSInteger {
    case callBackFirst = 1, callBackSecond, callBackThird, callBackFourth, callBackFifth, callBackSixth, callBackSeventh, callBackEighth, callBackTenth, callBackNinth
};

extension Dictionary {
    mutating func merge<S>(_ other: S)
        where S: Sequence, S.Iterator.Element == (key: Key, value: Value){
            for (k ,v) in other {
                self[k] = v
        }
    }
}

 class Router: NSObject {

    public static let shared = Router()
    
    var cachDict  = [String : AnyObject]()
    var dataDict  = [String : AnyObject]()
    
    typealias handle = (_ param:Any , _ nav:UINavigationController?, _ jumpType:RouterJumpType, _ fromVC:UIViewController?, _ animaled: Bool) -> ()
    
    typealias callBackBlock = (_ param:AnyObject , _ type:String) -> ()

    typealias completion = () -> ()

    
    func registerUrl(urlString:String? , calss:AnyClass, handler:@escaping handle) {
        
        guard let urlStr = urlString else {
            return
        }
                
        func getRouterDict(urlString:String? , calss:AnyClass, handler:@escaping handle) -> Dictionary<String, Any> {
            return [
                routerKey:urlStr,
                classKey:AnyClass.self,
                blockKey:handler
            ]
        }
        
        let keyString = getCachKey(urlPattern: urlStr)
        let routerDict = getRouterDict(urlString: urlStr, calss: calss, handler: handler)

        if let key = keyString {
            cachDict[key] = routerDict as AnyObject
        }
    }
    
    func deregisterURL(urlString:String?) {
        let keyString: String = getCachKey(urlPattern: urlString ?? "")!
        cachDict.removeValue(forKey: keyString)
    }
    
    @discardableResult public func jumpType(_ type: RouterJumpType) -> Self {
        dataDict[routerTypeKey] = type as AnyObject
        return self
    }
    
    @discardableResult public func fromVC(_ from :UIViewController) -> Self {
        dataDict[rouderFromVcKey] = from
        return self
    }
    
    @discardableResult public func toVC(_ tovc :UIViewController) -> Self {
        dataDict[rouderToVcKey] = tovc
        return self
    }
    
    @discardableResult public func fromNav(_ nav :UIViewController) -> Self {
        dataDict[routerNavKey] = nav as AnyObject
        return self
    }
    
    @discardableResult public func callBackBlock(_ callBack :@escaping callBackBlock) -> Self {
        dataDict[backBlockKey] = callBack as AnyObject
        return self
    }
    
    @discardableResult public func completion(_ block :@escaping completion) -> Self {
        dataDict[routerCompletionKey] = block as AnyObject
        return self
    }

    @discardableResult public func animated(_ animated :Bool) -> Self {
        dataDict[routerAnimatedKey] = animated as AnyObject
        return self
    }
    
    @discardableResult public func openUrl(_ urlString: String, _ param: Dictionary<String, Any> = [:]) -> Self {

        var fromVC: UIViewController? = dataDict[rouderFromVcKey] as? UIViewController
        if fromVC == nil {
            fromVC = dataDict[routerClassKey] as? UIViewController
        }

        
        let nav: UIViewController? = dataDict[routerNavKey] as? UIViewController
        guard let navValue = nav else { return self }
        let finalNav:UINavigationController? = getNav(vc: navValue)

        
        var animated: Bool = true
        if dataDict[routerAnimatedKey] != nil {
            animated = dataDict[routerAnimatedKey] as! Bool
        }
              
    
        var jumpType:RouterJumpType = .push
        if dataDict[routerTypeKey] != nil {
            jumpType = dataDict[routerTypeKey] as! RouterJumpType
        }


        var paramDict: Dictionary<String, Any> = analysisUrl(urlStr: urlString)
        if param.count != 0 {
            paramDict.merge(param)
        }
        
        
        let cachDictKey: String? = getCachKey(urlPattern: urlString)
        var cachParam: Dictionary<String, Any>? = cachDict[cachDictKey ?? ""] as? Dictionary
        let backBlock: callBackBlock? = dataDict[backBlockKey] as? Router.callBackBlock
        
        if backBlock != nil {
            cachParam?[backBlockKey] = backBlock
        }
                
        let keyString = getCachKey(urlPattern: urlString)
        let routerDict = cachDict[keyString ?? ""]
        let handler: handle? = routerDict?[blockKey] as? Router.handle
        guard let finalHandler = handler else { return self}
        finalHandler(paramDict, finalNav, jumpType, fromVC, animated)
        
        dataDict.removeAll()
        paramDict.removeAll()
        
        return self
    }
    
    func getCachKey(urlPattern: String) -> String? {
         let url: URL? = URL(string: urlPattern)
         
         if let host = url?.host, let path = url?.path {
             return host + path
         }
         
         return ""
     }
    
    func getNav(vc: UIViewController) -> UINavigationController? {
        if vc.isKind(of: UINavigationController.self) {
            return vc as? UINavigationController
        } else if vc.isKind(of: UIViewController.self) {
            return vc.navigationController
        }
        return nil
    }


    @discardableResult func closeWithUrl(_ urlString: String, _ completion: @escaping completion = {}) -> Self {
        
        var fromVC: UIViewController? = dataDict[rouderFromVcKey] as? UIViewController
        if fromVC == nil {
            fromVC = dataDict[routerClassKey] as? UIViewController
        }
        
        let toVC:UIViewController? = dataDict[rouderToVcKey] as? UIViewController

        var jumpType:RouterJumpType = .pop
        if dataDict[routerTypeKey] != nil {
            jumpType = dataDict[routerTypeKey] as! RouterJumpType
        }
        
        let nav: UIViewController? = dataDict[routerNavKey] as? UIViewController
        guard let navValue = nav else { return self}
        let finalNav:UINavigationController? = getNav(vc: navValue)
        
        
        var animated: Bool = true
        if dataDict[routerAnimatedKey] != nil {
            animated = dataDict[routerAnimatedKey] as! Bool
        }
        
        dataDict.removeAll()

        switch jumpType {
        case .pop: do {
            guard let navigation = finalNav else { return self}
            popViewController(nav: navigation, animated: animated)
        }
        case .popSome: do {
            guard let finalToVC = toVC, let navigation = finalNav else { return self}
            popToSomeViewControlelr(nav: navigation, tovc: finalToVC, animated: animated)
        }
        case .popRoot: do {
            guard let navigation = finalNav else { return self}
            popToRootViewController(nav: navigation, animated: animated)
        }
        case .dismiss: do {
            guard let vcOrnav = nav else { return self}
            dissmissViewController(nav: vcOrnav, animated: animated, completion: completion)
        }
        default:
            guard let navigation = finalNav else { return self}
            popViewController(nav: navigation, animated: animated)
            return self
        }

        return self
    }
    
    
    func popViewController(nav:UINavigationController, animated: Bool) {
        nav.popViewController(animated: animated)
    }
    
    func popToSomeViewControlelr(nav:UINavigationController, tovc: UIViewController, animated: Bool) {
        nav.popToViewController(tovc, animated: animated)
    }
    
    func popToRootViewController(nav:UINavigationController, animated: Bool) {
        nav.popToRootViewController(animated: animated)
    }
    
    func dissmissViewController(nav:UIViewController, animated: Bool, completion: @escaping completion) {
        
        func dismiss(nav:UIViewController, animated: Bool) {
            nav.dismiss(animated: animated) {
                completion()
            }
        }
        
        if Thread.isMainThread {
            dismiss(nav: nav, animated: animated)
        } else {
            DispatchQueue.main.async {
                dismiss(nav: nav, animated: animated)
            }
        }

    }
    
    func analysisUrl(urlStr: String?) -> Dictionary<String, Any>  {
        var paramDict = [String : Any]()
        guard let urlString = urlStr else { return [:]}
       let url = NSURL(string: urlString)
       
       let paramString: String? = url?.query
       let paramArray: Array? = paramString?.components(separatedBy: "&")
       if paramArray?.count == 0 {
        return [:]
       }
       
       for string: String in paramArray! {
           let parArr = string.components(separatedBy: "=")
           if parArr.count > 1 {
               let key = parArr[0];
               let value = parArr[1];
            paramDict[key] = value
           }
       }
        return paramDict
   }
    
    class func router(_ any:Any = self) -> Router {
           let rout = Router.shared
           rout.dataDict[routerClassKey] = any as AnyObject
           return rout
       }

    func registerModules(modulesArray: Array<AnyClass>) {
        for moduleName in modulesArray {
            performTarget(moduleName, actionName: "registerURL", [:] as AnyObject, {})
        }
    }
    
    @discardableResult func performTarget(_ targetClass: AnyClass, actionName: String, _ viewDataModel: Any = "" as Any, _ callBack:Any = {}) -> AnyObject? {
        let selector  = NSSelectorFromString(actionName)
        if let targetCls = targetClass as AnyObject as? NSObjectProtocol {
            if targetCls.responds(to: selector){
                
                let result = targetCls.perform(selector, with: viewDataModel, with: callBack)
                if result != nil {
                    return result?.takeRetainedValue()
                }
            }
        }
        return nil
    }
    
    @discardableResult func postModuleWithTarget(_ targetClass: AnyClass, _ aSelectorName: String, _ object: Any = "" as Any, _ callBack:Any = {}) -> AnyObject? {
        
        return performTarget(targetClass, actionName: aSelectorName, object, callBack)
    }
    
}


