//
//  ViewControllerTwo.swift
//  Router
//
//  Created by caoye on 2020/5/26.
//  Copyright © 2020 caoye. All rights reserved.
//

import UIKit

class ViewControllerTwo: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        btn.addTarget(self, action: #selector(btnclick), for: .touchUpInside)
        btn.backgroundColor = .red
        self.view.addSubview(btn)
    }
    
    @objc func btnclick() {

       Router.router().fromNav(self).closeWithUrl("", {
            print("dismiss")
        })
    }

}
