//
//  ModuleManagerA.swift
//  Router
//
//  Created by caoye on 2020/5/26.
//  Copyright © 2020 caoye. All rights reserved.
//

import UIKit

class ModuleManagerA: NSObject {

    static let viewControllerTwoUrl = "router://ViewControllerTwo.com?name=zhangsan&age=20"
    
   @objc public class func registerURL() {
        Router.router().registerUrl(urlString: ModuleManagerA.viewControllerTwoUrl, calss: ViewControllerTwo.self) { (paramDict, nav, jumType, vc, animaled) in
            let vc = ViewControllerTwo()
            nav?.pushViewController(vc, animated: animaled)
        }
    }
    
    
    @objc class func test(_ par1:String, _ para2:@escaping(_ name:String)->())  -> String {
        
        print(par1, "caoye")
        return "99999999"
    }

    @objc class func test() -> String {
          return "567899"
      }
}
