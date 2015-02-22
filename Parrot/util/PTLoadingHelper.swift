//
//  PTLoadingHelper.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc protocol PTLoadingHelperDelegate {
    optional func madeProgress(progress: Float)
    optional func completedWithNoObjects()
    optional func completedWithObjects(newObjects: [PTObject])
}

class PTLoadingHelper: NSObject, NSXMLParserDelegate {
    
    var delegate: PTLoadingHelperDelegate!
    
    var pocketDone = false
    var deliciousDone = false
    
    init(delegate: PTLoadingHelperDelegate) {
        super.init()
        
        self.delegate = delegate
        
        retrievePocket()
        retrieveDelicious()
    }
    
    func retrievePocket() {
        let url = NSURL(string: "https://getpocket.com/v3/get")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json; charset=UTF8", forHTTPHeaderField: "Content-Type")
        
        let body = ["consumer_key": pocketConsumerKey, "access_token": pocketAccessToken]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: nil)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            let json = JSON(data: data)
            if let list = json["list"].dictionary {
                for (item_id, dict) in list {
                    if let data = dict.dictionary {
                        if let title = data["resolved_title"]?.string {
                            if let url = data["resolved_url"]?.string {
                                let object = PTObject()
                                object.title = title
                                object.url = NSURL(string: url)!
                                objects.append(object)
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
            Alamofire.request(.GET, "http://api.diffbot.com/v3/article", parameters: ["token": diffbotToken, "url": object.url.absoluteString!]).response({ (request, response, data, error) -> Void in
                let json = JSON(data: data as NSData)
                if let objs = json["objects"].array {
                    for obj in objs {
                        if let objct = obj.dictionary {
                            if let text = objct["text"]?.string {
                                object.text = text
                                newObjects.append(object)
                            }
                        }
                    }
                }
                
                completed += 1
                self.delegate.madeProgress!(1 / Float(objects.count) * Float(completed))
                
                if completed == objects.count {
                    self.delegate.completedWithObjects!(newObjects)
                }
            })
        }
        
        if objects.count == 0 {
            delegate.completedWithNoObjects!()
        }
    }
}
