//
//  ViewController.swift
//  Router
//
//  Created by caoye on 2020/5/26.
//  Copyright © 2020 caoye. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBAction func Click(_ sender: Any) {

        Router.router().fromNav(self).callBackBlock({ (param, callType) in
            print(param, callType)
        }).openUrl(ModuleManagerA.viewControllerTwoUrl)
        
        let tt = Router.router().postModuleWithTarget(ModuleManagerA.self, "test::", "234", {a in

            print(a)
        })
        print(tt!)

//        let tt = Router.router().postModuleWithTarget(ModuleManagerA.self, "test")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        

    }

 
}

