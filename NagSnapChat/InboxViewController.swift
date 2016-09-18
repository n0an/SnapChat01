//
//  InboxViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import AVKit
import AVFoundation


class InboxViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    struct Storyboard {
        static let showLoginSegue = "Show Log In"
        static let showPhotoSegue = "Show Photo"

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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InboxViewController.fetchMessages), name: "reloadMessages", object: nil)
        
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false

        fetchMessages()
    }
    
    // MARK: - HELPER METHODS
    
    // !!!IMPORTANT!!!
    func updateTabBarBadge() {
        let tabArray = (self.tabBarController?.tabBar.items)!
        let inboxItem = tabArray[0]
        
        if self.messages.count > 0 {
            inboxItem.badgeValue = "++\(self.messages.count)"
        } else {
            inboxItem.badgeValue = nil

        }
    }
    
    func fetchMessages() {
        if let currentUser = PFUser.currentUser() {
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.whereKey("recipientIds", equalTo: currentUser.objectId!)
            messageQuery.orderByDescending("createdAt")
            
            messageQuery.findObjectsInBackgroundWithBlock({ (messages, error) in
                if error == nil, let messages = messages {
                    self.messages = messages
                    self.tableView.reloadData()
                    
                    self.updateTabBarBadge()
                    
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
            
        } else if segue.identifier == Storyboard.showPhotoSegue {
            let photoVC = segue.destinationViewController as! PhotoViewController
            
            photoVC.message = self.selectedMessage
            
            photoVC.hidesBottomBarWhenPushed = true
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let message = self.messages[indexPath.row]
        
        cell.textLabel?.text = message["senderName"] as? String
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let message = self.messages[indexPath.row]
        
        let fileType = message["fileType"] as! String
        
        self.selectedMessage = message
        
        if fileType == "photo" {
            // it is a photo message
            self.performSegueWithIdentifier(Storyboard.showPhotoSegue, sender: nil)
        } else {
            // it is a video message
            
            let videoFile = self.selectedMessage["file"] as! PFFile
            let fileURL = NSURL(string: videoFile.url!)
            let player = AVPlayer(URL: fileURL!)
            
            let playerVC = AVPlayerViewController()

            playerVC.player = player
            
            self.presentViewController(playerVC, animated: true, completion: { 
                playerVC.player?.play()
            })
        }
        
        // delete message after showing
        
        var recipientIds = self.selectedMessage["recipientIds"] as! [String]
        if recipientIds.count == 1 {
            self.selectedMessage.deleteInBackground()
        } else {
            let currentUserObjectId = PFUser.currentUser()!.objectId!
            if let index = recipientIds.indexOf(currentUserObjectId) {
                recipientIds.removeAtIndex(index)
            }
            
            self.selectedMessage["recipientIds"] = recipientIds
            
            self.selectedMessage.saveInBackground()
        }
        
        
    }

    
    
    
    
    
    
}









