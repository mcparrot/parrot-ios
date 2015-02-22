//
//  LoadingViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, NSXMLParserDelegate {
    
    var pocketDone = false
    var deliciousDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objects = [PTObject]()
        
        renewServices()
        initializeEverything()
    }
    
    func initializeEverything() {
        SVProgressHUD.setOffsetFromCenter(UIOffsetMake(0, 250))
        SVProgressHUD.showProgress(0)
        
        self.navigationController?.navigationBar.hidden = true
        
        if pocketAuthenticated {
            retrievePocket()
        } else {
            pocketDone = true
        }
        
        if deliciousAuthenticated {
            retrieveDelicious()
        } else {
            deliciousDone = true
        }
        
        retrieveText()
    }
    
    func retrievePocket() {
        let url = NSURL(string: "https://getpocket.com/v3/get")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json; charset=UTF8", forHTTPHeaderField: "Content-Type")
        
        let body = ["consumer_key": pocketConsumerKey, "access_token": pocketAccessToken]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: nil)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let result = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                if let list = result["list"] as? NSDictionary {
                    for (item_id, dict) in list {
                        if let data = dict as? NSDictionary {
                            if let title = data["resolved_title"] as? String {
                                if let url = data["resolved_url"] as? String {
                                    let object = PTObject()
                                    object.title = title
                                    object.url = NSURL(string: url)!
                                    objects.append(object)
                                }
                            }
                        }
                    }
                }
            }
            
            self.pocketDone = true
            self.retrieveText()
        }
    }
    
    func retrieveDelicious() {
        let url = NSURL(string: "https://api.del.icio.us/v1/posts/all")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(deliciousAccessToken)", forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            let parser = NSXMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        if elementName == "post" {
            let title = attributeDict["description"] as String
            let url = attributeDict["href"] as String
            
            let object = PTObject()
            object.title = title
            object.url = NSURL(string: url)!
            objects.append(object)
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        deliciousDone = true
        retrieveText()
    }
    
    func retrieveText() {
        if !(pocketDone && deliciousDone) {
            return
        }
        
        var completed = 0
        
        var newObjects = [PTObject]()
        for object in objects {
            let url = NSURL(string: "http://api.diffbot.com/v3/article?token=\(diffbotToken)&url=\(object.url)")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                if let result = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
                    if let objs = result["objects"] as? NSArray {
                        for obj in objs {
                            if let objct = obj as? NSDictionary {
                                if let text = objct["text"] as? String {
                                    object.text = text
                                    newObjects.append(object)
                                }
                            }
                        }
                    }
                    
                    completed += 1
                    SVProgressHUD.showProgress(1 / Float(objects.count) * Float(completed))
                }
                
                if completed == objects.count {
                    SVProgressHUD.showProgress(1)
                    objects = newObjects
                    self.performSegueWithIdentifier("librarySegue", sender: self)
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        SVProgressHUD.dismiss()
    }
}
