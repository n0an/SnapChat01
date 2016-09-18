//
//  FriendsTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class FriendsTableViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
        static let showEditFriendsSegue = "Show Edit Friends"
    }
    
    var friends = [PFUser]()
    var currentUser: PFUser!
    var friendsRelation: PFRelation!
    
    
    // MARK: - viewWillAppear

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriends()
    }
    
    // MARK: - HELPER METHODS
    
    func fetchFriends() {
        currentUser = PFUser.currentUser()!
        
        if let friendsRelation = currentUser["friendsRelation"] as? PFRelation {
            let friendsQuery = friendsRelation.query()
            friendsQuery.orderByAscending("username")
            
            friendsQuery.findObjectsInBackgroundWithBlock({ (friends, error) in
                if error == nil {
                    self.friends = friends as! [PFUser]
                    self.tableView.reloadData()
                } else {
                    
                    let alertVC = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alertVC.addAction(okAction)
                    
                    self.presentViewController(alertVC, animated: true, completion: nil)
                    

                    print(error)
                }
            })
        }
    }
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.showEditFriendsSegue {
            let editFriendsVC = segue.destinationViewController as! EditFriendsTableViewController
            editFriendsVC.friends = self.friends
        }
    }
    
    
    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let friend = self.friends[indexPath.row]
        
        cell.textLabel?.text = friend.username
        
        return cell
    }

    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}







