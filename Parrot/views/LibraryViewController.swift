//
//  LibraryViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var objectToSend: PTObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell") as UITableViewCell
        
        let titleLabel = cell.contentView.viewWithTag(10) as UILabel
        let taglineLabel = cell.contentView.viewWithTag(11) as UILabel
        
        titleLabel.text = objects[indexPath.row].title
        taglineLabel.text = objects[indexPath.row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        objectToSend = objects[indexPath.row]
        
        self.performSegueWithIdentifier("displaySegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as DisplayViewController
        dvc.object = objectToSend
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
