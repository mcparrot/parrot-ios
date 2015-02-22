//
//  LoadingViewController.swift
//  Parrot
//
//  Created by Jack Cook on 2/22/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoadingViewController: UIViewController, PTLoadingHelperDelegate {
    
    var pocketDone = false
    var deliciousDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setOffsetFromCenter(UIOffsetMake(0, 250))
        SVProgressHUD.showProgress(0)
        
        renewServices()
        
        self.navigationController?.navigationBar.hidden = true
        
        let helper = PTLoadingHelper(delegate: self)
    }
    
    func madeProgress(progress: Float) {
        SVProgressHUD.showProgress(progress)
    }
    
    func completedWithNoObjects() {
        self.performSegueWithIdentifier("librarySegue", sender: self)
    }
    
    func completedWithObjects(newObjects: [PTObject]) {
        SVProgressHUD.showProgress(1)
        objects = newObjects
        self.performSegueWithIdentifier("librarySegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        SVProgressHUD.dismiss()
    }
}
