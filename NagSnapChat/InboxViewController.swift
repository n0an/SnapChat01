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
    
    var messages = [PFObject]()
    fileprivate var selectedMessage: PFObject!

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.current() == nil {
            performSegue(withIdentifier: Storyboard.showLoginSegue, sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InboxViewController.fetchMessages), name: NSNotification.Name(rawValue: "reloadMessages"), object: nil)
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadMessages"), object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false

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
        if let currentUser = PFUser.current() {
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.whereKey("recipientIds", equalTo: currentUser.objectId!)
            messageQuery.order(byDescending: "createdAt")
            
            messageQuery.findObjectsInBackground(block: { (messages, error) in
                if error == nil, let messages = messages {
                    self.messages = messages
                    self.tableView.reloadData()
                    
                    self.updateTabBarBadge()
                    
                } else {
                    
                    let alertVC = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alertVC.addAction(okAction)
                    
                    self.present(alertVC, animated: true, completion: nil)
                    
                    print(error)
                }
                
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    // MARK: - ACTIONS
    
    @IBAction func refresh(_ sender: AnyObject) {
        print("refresh")
        fetchMessages()
    }
    
    @IBAction func logOutDidTap(_ sender: AnyObject) {
        PFUser.logOut()
        self.performSegue(withIdentifier: Storyboard.showLoginSegue, sender: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showLoginSegue {
            let loginSignUpVC = segue.destination as! LoginSignupViewController
            
            // !!!IMPORTANT
            loginSignUpVC.hidesBottomBarWhenPushed = true
            loginSignUpVC.navigationItem.hidesBackButton = true
            
        } else if segue.identifier == Storyboard.showPhotoSegue {
            let photoVC = segue.destination as! PhotoViewController
            
            photoVC.message = self.selectedMessage
            
            photoVC.hidesBottomBarWhenPushed = true
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdentifier, for: indexPath)
        
        let message = self.messages[indexPath.row]
        
        cell.textLabel?.text = message["senderName"] as? String
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let message = self.messages[indexPath.row]
        
        let fileType = message["fileType"] as! String
        
        self.selectedMessage = message
        
        if fileType == "photo" {
            // it is a photo message
            self.performSegue(withIdentifier: Storyboard.showPhotoSegue, sender: nil)
        } else {
            // it is a video message
            
            let videoFile = self.selectedMessage["file"] as! PFFile
            let fileURL = URL(string: videoFile.url!)
            let player = AVPlayer(url: fileURL!)
            
            let playerVC = AVPlayerViewController()

            playerVC.player = player
            
            self.present(playerVC, animated: true, completion: { 
                playerVC.player?.play()
            })
        }
        
        // delete message after showing
        
        var recipientIds = self.selectedMessage["recipientIds"] as! [String]
        if recipientIds.count == 1 {
            self.selectedMessage.deleteInBackground()
        } else {
            let currentUserObjectId = PFUser.current()!.objectId!
            if let index = recipientIds.index(of: currentUserObjectId) {
                recipientIds.remove(at: index)
            }
            
            self.selectedMessage["recipientIds"] = recipientIds
            
            self.selectedMessage.saveInBackground()
        }
        
        
    }

    
    
    
    
    
    
}









