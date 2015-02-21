//
//  PTAuthentication.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

let pocketConsumerKey = "38311-2a981099b43e762b56a03932"
let pocketRedirectUri = "parrot-login://pocket"
var pocketRequestCode = ""
var pocketAccessToken = ""
var pocketUsername = ""

func authenticatePocket() {
    let accessToken = SSKeychain.passwordForService("parrot", account: "pocket")
    if let at = accessToken {
        pocketAccessToken = accessToken
        // ???
    } else {
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
        pocketUsername = stuff[1].componentsSeparatedByString("=")[1]
        
        SSKeychain.setPassword(pocketAccessToken, forService: "parrot", account: "pocket")
    }
}
