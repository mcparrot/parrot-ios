//
//  ViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    
    @IBOutlet var speedSlider: PTSlider!
    @IBOutlet var progressSlider: PTSlider!
    
    @IBOutlet var drawerView: UIView!
    
    @IBOutlet var drawerButton: UIButton!
    @IBOutlet var bottomDrawerConstraint: NSLayoutConstraint!
    
    var words = [String]()
    var current = 0
    var paused = true
    var drawer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pocketAuthenticated", name: pocketAuthenticatedNotification, object: nil)
        
        authenticatePocket()
        
        speedSlider.configureFlatSliderWithTrackColor(UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1), progressColor: UIColor(red: 1, green: 0.81, blue: 0.77, alpha: 1), thumbColor: UIColor(red: 0.96, green: 0.31, blue: 0.18, alpha: 1))
        progressSlider.configureFlatSliderWithTrackColor(UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1), progressColor: UIColor(red: 1, green: 0.81, blue: 0.77, alpha: 1), thumbColor: UIColor(red: 0.96, green: 0.31, blue: 0.18, alpha: 1))
        
        progressSlider.setThumbImage(UIImage(), forState: .Normal)
        progressSlider.userInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        println(drawerButton.frame.origin.y)
    }
    
    @IBAction func drawerButton(sender: AnyObject) {
        bottomDrawerConstraint.constant = drawer ? -298 : 0
        drawerView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.drawerView.layoutIfNeeded()
        })
        
        drawer = !drawer
    }
    
    func pocketAuthenticated() {
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
                            if let item_id = data["item_id"] as? String {
                                if let title = data["resolved_title"] as? String {
                                    if let url = data["resolved_url"] as? String {
                                        if let status = dict["status"] as? String {
                                            if let word_count = dict["word_count"] as? String {
                                                let object = PTObject()
                                                object.item_id = item_id.toInt()!
                                                object.title = title
                                                object.url = NSURL(string: url)!
                                                object.status = status.toInt()!
                                                object.word_count = status.toInt()!
                                                objects.append(object)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            self.retrieveText()
        }
    }
    
    func retrieveText() {
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
                                }
                            }
                        }
                    }
                }
                
                self.retrievalDone()
            })
        }
    }
    
    func retrievalDone() {
        let text = objects[0].text
        for word in text.componentsSeparatedByString(" ") {
            words.append(word)
        }
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1 / 6, target: self, selector: "updateWord", userInfo: nil, repeats: true)
    }
    
    func updateWord() {
        if !paused {
            wordLabel.text = words[current]
            current += 1
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
