//
//  LibraryViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved. Wow such copyright
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PTLoadingHelperDelegate {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var tableObjects = [PTObject]()
    var objectToSend: PTObject!
    
    var transparencyView: UIButton!
    
    var pocketDone = false
    var deliciousDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableObjects = objects
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChanged", name:
            UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: pocketAuthenticatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: deliciousAuthenticatedNotification, object: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell") as UITableViewCell
        
        let titleLabel = cell.contentView.viewWithTag(10) as UILabel
        let taglineLabel = cell.contentView.viewWithTag(11) as UILabel
        
        titleLabel.text = tableObjects[indexPath.row].title
        taglineLabel.text = tableObjects[indexPath.row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        objectToSend = tableObjects[indexPath.row]
        
        self.performSegueWithIdentifier("displaySegue", sender: self)
    }
    
    func textFieldChanged() {
        tableObjects = [PTObject]()
        
        for object in objects {
            if (object.title.lowercaseString.rangeOfString(textField.text.lowercaseString) != nil) || (textField.text == "") {
                tableObjects.append(object)
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let deviceSize = UIScreen.mainScreen().bounds
        
        transparencyView = UIButton(frame: deviceSize)
        transparencyView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        transparencyView.alpha = 0
        transparencyView.addTarget(self, action: "transparencyButton", forControlEvents: .TouchUpInside)
        
        let alert = UIView(frame: CGRectMake(deviceSize.width / 6, deviceSize.height / 3, deviceSize.width * (2/3), deviceSize.height * (1/3)))
        alert.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        alert.layer.cornerRadius = 12
        
        let shadowPath = UIBezierPath(rect: alert.bounds)
        alert.layer.masksToBounds = false
        alert.layer.shadowColor = UIColor.blackColor().CGColor
        alert.layer.shadowOffset = CGSizeMake(0, 0)
        alert.layer.shadowOpacity = 0.25
        alert.layer.shadowPath = shadowPath.CGPath
        
        let title = UILabel()
        title.text = "SIGN IN"
        title.font = UIFont(name: "AvenirNext-Regular", size: 20)
        title.sizeToFit()
        title.frame = CGRectMake((alert.frame.size.width - title.frame.size.width) / 2, 26, title.frame.size.width, title.frame.size.height)
        
        let pocketButton = UIButton(frame: CGRectMake(32, title.frame.origin.y + title.frame.size.height + 22, alert.frame.size.width - 64, (alert.frame.size.width - 64) * (116/455)))
        pocketButton.setImage(UIImage(named: "pocket.png"), forState: .Normal)
        pocketButton.addTarget(self, action: "pocketButton", forControlEvents: .TouchUpInside)
        
        let deliciousButton = UIButton(frame: CGRectMake(32, pocketButton.frame.origin.y + pocketButton.frame.size.height + 28, alert.frame.size.width - 64, (alert.frame.size.width - 64) * (87/470)))
        deliciousButton.setImage(UIImage(named: "delicious.png"), forState: .Normal)
        deliciousButton.addTarget(self, action: "deliciousButton", forControlEvents: .TouchUpInside)
        
        alert.addSubview(title)
        alert.addSubview(pocketButton)
        alert.addSubview(deliciousButton)
        
        transparencyView.addSubview(alert)
        self.view.addSubview(transparencyView)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.transparencyView.alpha = 1
        })
    }
    
    func transparencyButton() {
        transparencyView.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.transparencyView.alpha = 0
        }) { (done) -> Void in
            self.transparencyView.removeFromSuperview()
        }
    }
    
    func pocketButton() {
        authenticatePocket()
        transparencyButton()
    }
    
    func deliciousButton() {
        authenticateDelicious()
        transparencyButton()
    }
    
    func reloadData() {
        objects = [PTObject]()
        
        SVProgressHUD.setOffsetFromCenter(UIOffsetZero)
        SVProgressHUD.showProgress(0)
        
        let helper = PTLoadingHelper(delegate: self)
        
        loginButton.userInteractionEnabled = false
        textField.userInteractionEnabled = false
        tableView.userInteractionEnabled = false
    }
    
    func madeProgress(progress: Float) {
        SVProgressHUD.showProgress(progress)
    }
    
    func completedWithObjects(newObjects: [PTObject]) {
        SVProgressHUD.dismiss()
        objects = newObjects
        self.tableObjects = objects
        self.tableView.reloadData()
        
        loginButton.userInteractionEnabled = true
        textField.userInteractionEnabled = true
        tableView.userInteractionEnabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as DisplayViewController
        dvc.object = objectToSend
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
