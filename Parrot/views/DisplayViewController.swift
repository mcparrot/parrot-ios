//
//  DisplayViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {

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
    
    var object: PTObject!
    var words = [String]()
    var current = 0
    var drawer = false
    var paused = false
    var favorite = false
    var countdown = 3
    
    var countdownTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeObject(object)
        
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
        
        startCountdown()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func drawerButton(sender: AnyObject) {
        countdownTimer.invalidate()
        countdown = 3
        
        bottomDrawerConstraint.constant = drawer ? -321 : 0
        drawerView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.drawerView.layoutIfNeeded()
        }) { (done) -> Void in
            if !self.drawer {
                self.startCountdown()
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
    
    func startCountdown() {
        paused = true
        wordLabel.text = "\(countdown)"
        wordLabel.font = UIFont(name: "AvenirNext-Regular", size: 128)
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "decrementCountdown", userInfo: nil, repeats: false)
    }
    
    func decrementCountdown() {
        countdown -= 1
        wordLabel.text = "\(countdown)"
        wordLabel.font = UIFont(name: "AvenirNext-Regular", size: 128)
        
        if countdown > 0 {
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "decrementCountdown", userInfo: nil, repeats: false)
        } else {
            paused = false
        }
    }
    
    func initializeObject(object: PTObject) {
        let text = object.text
        for word in text.componentsSeparatedByString(" ") {
            words.append(word)
        }
        
        self.titleLabel.text = object.title
        
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
            if current >= words.count {
                let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "pop", userInfo: nil, repeats: false)
            } else {
                wordLabel.text = words[current]
                wordLabel.font = UIFont(name: "AvenirNext-Regular", size: 56)
                current += 1
                self.progressLabel.text = "\(current) / \(words.count) words"
                self.progressSlider.maximumValue = Float(words.count)
                self.progressSlider.value = Float(current)
            }
        }
        
        let speed = Double(1 / (speedSlider.value / 60))
        let timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "updateWord", userInfo: nil, repeats: false)
    }
    
    func pop() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
