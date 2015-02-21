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
        PocketAPI.sharedAPI().URLScheme = "parrot-login"
        PocketAPI.sharedAPI().consumerKey = "38311-2a981099b43e762b56a03932"
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if PocketAPI.sharedAPI().handleOpenURL(url) {
            return true
        }
        
        return false
    }
}
