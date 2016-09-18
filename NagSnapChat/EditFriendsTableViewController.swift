//
//  EditFriendsTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class EditFriendsTableViewController: UITableViewController {
    
    
    // MARK: - PROPERTIES
    
    let cellAccessoryColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    
    var friends = [PFUser]()
    private var users = [PFUser]()
    
    private var currentUser = PFUser.currentUser()!
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Friends"
        
        fetchUsers()

        
    }
    
    // MARK: - HELPER METHODS
    
    private func fetchUsers() {
        let userQuery = PFUser.query()
        userQuery?.orderByAscending("username")
        userQuery?.findObjectsInBackgroundWithBlock({ (users, error) in
            
            if error == nil {
                self.users = users as! [PFUser]
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
    
    private func isFriendWith(user: PFUser) -> Bool {
        
        for friend in friends {
            if friend.objectId == user.objectId {
                return true
            }
        }
        
        return false
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let user = self.users[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        if isFriendWith(user) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = self.users[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let friendsRelation = currentUser.relationForKey("friendsRelation")

        
        if isFriendWith(user) {
            // unfriend
            cell?.accessoryType = .None
            
            for friend in self.friends {
                if friend.objectId == user.objectId {
                    let indexToRemove = self.friends.indexOf(friend)
                    self.friends.removeAtIndex(indexToRemove!)
                }
            }
            

            
            friendsRelation.removeObject(user)
            
        } else {
            // add friendship
            cell?.accessoryType = .Checkmark
            
            friends.append(user)
            
            friendsRelation.addObject(user)
        }
        
        
        
        
        
        currentUser.saveInBackgroundWithBlock { (success, error) in
            if error != nil {
                print(error)
            }
        }
    }


    

}











