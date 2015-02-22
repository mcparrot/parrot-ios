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
    
    @IBOutlet var wpmLabel: UILabel!
    @IBOutlet var speedSlider: PTSlider!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressSlider: PTSlider!
    
    @IBOutlet var drawerView: UIView!
    
    @IBOutlet var drawerButton: UIButton!
    @IBOutlet var bottomDrawerConstraint: NSLayoutConstraint!
    
    @IBOutlet var favoriteButton: UIButton!
    
    var words = [String]()
    var current = 0
    var drawer = false
    var paused = false
    var favorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pocketAuthenticated", name: pocketAuthenticatedNotification, object: nil)
        
        authenticatePocket()
        
        speedSlider.configureFlatSliderWithTrackColor(UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1), progressColor: UIColor(red: 1, green: 0.81, blue: 0.77, alpha: 1), thumbColor: UIColor(red: 0.96, green: 0.31, blue: 0.18, alpha: 1))
        progressSlider.configureFlatSliderWithTrackColor(UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1), progressColor: UIColor(red: 1, green: 0.81, blue: 0.77, alpha: 1), thumbColor: UIColor(red: 0.96, green: 0.31, blue: 0.18, alpha: 1))
        
        drawerView.clipsToBounds = false
        
        let shadowPath = UIBezierPath(rect: drawerView.bounds)
        drawerView.layer.masksToBounds = false
        drawerView.layer.shadowColor = UIColor.blackColor().CGColor
        drawerView.layer.shadowOffset = CGSizeMake(0, -6)
        drawerView.layer.shadowOpacity = 0
        drawerView.layer.shadowPath = shadowPath.CGPath
        
        bottomDrawerConstraint.constant = -321
    }
    
    @IBAction func drawerButton(sender: AnyObject) {
        bottomDrawerConstraint.constant = drawer ? -321 : 0
        drawerView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.drawerView.layoutIfNeeded()
        }) { (done) -> Void in
            if !self.drawer {
                self.paused = false
            }
        }
        
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = drawer ? 0.25 : 0
        animation.toValue = drawer ? 0 : 0.25
        animation.duration = 0.5
        drawerView.layer.addAnimation(animation, forKey: "shadowOpacity")
        drawerView.layer.shadowOpacity = drawer ? 0 : 0.25
        
        if !self.drawer {
            self.paused = true
        }
        
        drawer = !drawer
    }
    
    @IBAction func speedSlider(sender: AnyObject) {
        let value = Int(speedSlider.value)
        wpmLabel.text = "\(value) words per minute"
    }
    
    @IBAction func progressSlider(sender: AnyObject) {
        current = Int(progressSlider.value)
        self.progressLabel.text = "\(current) / \(words.count) words"
    }
    
    @IBAction func favoriteButton(sender: AnyObject) {
        favorite = !favorite
        favoriteButton.setImage(favorite ? UIImage(named: "favorite-pressed.png") : UIImage(named: "favorite.png"), forState: .Normal)
    }
    
    @IBAction func bookmarkButton(sender: AnyObject) {
    }
    
    @IBAction func shareButton(sender: AnyObject) {
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        paused = true
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if paused && !drawer {
            paused = false
        }
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
                                                println(object.item_id)
                                                object.title = title
                                                object.url = NSURL(string: url)!
                                                object.status = status.toInt()!
                                                object.word_count = status.toInt()!
                                                objects.append(object)
                                                
                                                self.titleLabel.text = object.title
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
        
        wordLabel.text = words[current]
        current += 1
        self.progressLabel.text = "\(current) / \(words.count) words"
        self.progressSlider.maximumValue = Float(words.count)
        self.progressSlider.value = Float(current)
        
        let value = Int(speedSlider.value)
        wpmLabel.text = "\(value) words per minute"
        
        let speed = Double(1 / Int(speedSlider.value))
        let timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "updateWord", userInfo: nil, repeats: false)
    }
    
    func updateWord() {
        if !paused {
            wordLabel.text = words[current]
            current += 1
            self.progressLabel.text = "\(current) / \(words.count) words"
            self.progressSlider.maximumValue = Float(words.count)
            self.progressSlider.value = Float(current)
        }
        
        let speed = Double(1 / (speedSlider.value / 60))
        let timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "updateWord", userInfo: nil, repeats: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
