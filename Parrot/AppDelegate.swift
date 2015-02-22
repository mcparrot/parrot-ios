//
//  AppDelegate.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lvc = storyboard.instantiateViewControllerWithIdentifier("LoadingViewController") as LoadingViewController
        self.window!.rootViewController!.presentViewController(lvc, animated: false, completion: nil)
        
        switch url.host! {
        case "pocket":
            authenticatePocketWithURL(url)
        case "delicious":
            authenticateDeliciousWithURL(url)
        default:
            println("Error authenticating service: \(url.host!)")
            println(url.absoluteString)
            return false
        }
        
        return true
    }
}
