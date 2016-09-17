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
    
    // MARK: - PROPERTIES
    
    struct Storyboard {
        static let showLoginSegue = "Show Log In"
        static let cellIdentifier = "Message Cell"
    }
    
    private var messages = [PFObject]()
    private var selectedMessage: PFObject!

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier(Storyboard.showLoginSegue, sender: nil)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false

        fetchMessages()
    }
    
    // MARK: - HELPER METHODS
    
    func fetchMessages() {
        if let currentUser = PFUser.currentUser() {
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.whereKey("recipientIds", equalTo: currentUser.objectId!)
            messageQuery.orderByDescending("createdAt")
            
            messageQuery.findObjectsInBackgroundWithBlock({ (messages, error) in
                if error == nil, let messages = messages {
                    self.messages = messages
                    self.tableView.reloadData()
                    
                } else {
                    
                    let alertVC = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alertVC.addAction(okAction)
                    
                    self.presentViewController(alertVC, animated: true, completion: nil)
                    
                    print(error)
                }
                
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    // MARK: - ACTIONS
    
    @IBAction func refresh(sender: AnyObject) {
        print("refresh")
        fetchMessages()
    }
    
    @IBAction func logOutDidTap(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier(Storyboard.showLoginSegue, sender: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.showLoginSegue {
            let loginSignUpVC = segue.destinationViewController as! LoginSignupViewController
            
            // !!!IMPORTANT
            loginSignUpVC.hidesBottomBarWhenPushed = true
            loginSignUpVC.navigationItem.hidesBackButton = true
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let message = self.messages[indexPath.row]
        
        cell.textLabel?.text = message.objectForKey("senderName") as? String
        
        return cell
    }
    
    
    
    
    
    
}









