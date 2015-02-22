//
//  LibraryViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var tableObjects = [PTObject]()
    var objectToSend: PTObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableObjects = objects
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChanged", name:
            UITextFieldTextDidChangeNotification, object: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as DisplayViewController
        dvc.object = objectToSend
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
