//
//  InboxViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class InboxViewController: UITableViewController {
    
    struct Storyboard {
        static let showLoginSegue = "Show Log In"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier(Storyboard.showLoginSegue, sender: nil)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false

    }
    
    // MARK: - Target / Action
    
    @IBAction func logOutDidTap(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier(Storyboard.showLoginSegue, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.showLoginSegue {
            let loginSignUpVC = segue.destinationViewController as! LoginSignupViewController
            
            //!!! IMPORTANT
            loginSignUpVC.hidesBottomBarWhenPushed = true
            loginSignUpVC.navigationItem.hidesBackButton = true
        }
    }
    
}
