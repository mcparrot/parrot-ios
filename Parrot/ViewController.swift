//
//  ViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PocketAPI.sharedAPI().loginWithHandler { (api, error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            } else {
                let key = "
                let token = NSUserDefaults.standardUserDefaults().objectForKey("PocketAPI.token") as String
                println(token)
                /*PocketAPI.sharedAPI().callAPIMethod("get", withHTTPMethod: PocketAPIHTTPMethodPOST, arguments: ["state": "unread"], handler: { (api, method, response, error) -> Void in
                    println("done")
                })*/
            }
        }
    }
}
