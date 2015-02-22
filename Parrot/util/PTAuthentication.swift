//
//  PTAuthentication.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import Alamofire
import SSKeychain
import UIKit

let pocketConsumerKey = "38330-5b53c97729230f2da7c5b3f5"
let pocketRedirectUri = "parrot-login://pocket"
var pocketRequestCode = ""
var pocketAccessToken = ""
let pocketAuthenticatedNotification = "PTPocketAuthenticatedNotification"
var pocketAuthenticated = false

func authenticatePocket() {
    let url = NSURL(string: "https://getpocket.com/v3/oauth/request")!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json; charset=UTF8", forHTTPHeaderField: "Content-Type")
    
    let body = ["redirect_uri": pocketRedirectUri, "consumer_key": pocketConsumerKey]
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: nil)
    
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
        let code = NSString(data: data, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("=")[1] as String
        pocketRequestCode = code
        let sendURL = NSURL(string: "https://getpocket.com/auth/authorize?request_token=\(code)&redirect_uri=\(pocketRedirectUri)&mobile=1")!
        UIApplication.sharedApplication().openURL(sendURL)
    }
}

func authenticatePocketWithURL(url: NSURL) {
    let url = NSURL(string: "https://getpocket.com/v3/oauth/authorize")!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json; charset=UTF8", forHTTPHeaderField: "Content-Type")
    
    let body = ["consumer_key": pocketConsumerKey, "code": pocketRequestCode]
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: nil)
    
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
        let stuff = NSString(data: data, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("&") as [String]
        pocketAccessToken = stuff[0].componentsSeparatedByString("=")[1]
        
        SSKeychain.setPassword(pocketAccessToken, forService: "parrot", account: "pocket")
        pocketAuthenticated = true
        NSNotificationCenter.defaultCenter().postNotificationName(pocketAuthenticatedNotification, object: nil)
    }
}


let deliciousClientID = "6c3f122a43247e6b267a8b2e6cbbef43"
let deliciousClientSecret = "9f2f43eb827e672a6f5d42f3a01cc9db"
let deliciousRedirectURI = "parrot-login://delicious"
let deliciousAuthenticatedNotification = "PTDeliciousAuthenticated"
var deliciousAccessToken = ""
var deliciousAuthenticated = false

func authenticateDelicious() {
    let url = NSURL(string: "https://delicious.com/auth/authorize?client_id=\(deliciousClientID)&redirect_uri=\(deliciousRedirectURI)")!
    UIApplication.sharedApplication().openURL(url)
}

func authenticateDeliciousWithURL(url: NSURL) {
    let code = url.query!.componentsSeparatedByString("=")[1]
    
    Alamofire.request(.POST, "https://avosapi.delicious.com/api/v1/oauth/token", parameters: ["client_id": deliciousClientID, "client_secret": deliciousClientSecret, "grant_type": "code", "redirect_uri": deliciousRedirectURI, "code": code]).response { (request, response, data, error) -> Void in
        if let result = NSJSONSerialization.JSONObjectWithData(data as NSData, options: .MutableContainers, error: nil) as? NSDictionary {
            if let access_token = result["access_token"] as? String {
                SSKeychain.setPassword(access_token, forService: "parrot", account: "delicious")
                deliciousAuthenticated = true
                NSNotificationCenter.defaultCenter().postNotificationName(deliciousAuthenticatedNotification, object: nil)
            }
        }
    }
}


func renewServices() -> Bool {
    let accessToken = SSKeychain.passwordForService("parrot", account: "pocket")
    if let at = accessToken {
        pocketAccessToken = accessToken
        pocketAuthenticated = true
        NSNotificationCenter.defaultCenter().postNotificationName(pocketAuthenticatedNotification, object: nil)
    }
    
    let accessToken2 = SSKeychain.passwordForService("parrot", account: "delicious")
    if let at = accessToken2 {
        deliciousAccessToken = accessToken2
        deliciousAuthenticated = true
        NSNotificationCenter.defaultCenter().postNotificationName(deliciousAuthenticatedNotification, object: nil)
    }
    
    return pocketAuthenticated || deliciousAuthenticated
}


let diffbotToken = "0d5c56d2a7a3a5a4ad6c644b326993c2"
